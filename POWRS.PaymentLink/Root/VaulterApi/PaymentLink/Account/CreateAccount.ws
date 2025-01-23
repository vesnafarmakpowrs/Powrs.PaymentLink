Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword)),
    "repeatedPassword":Required(Str(PRepeatedPassword)),
    "email" : Required(Str(PEmail)),
	"newSubUser": Optional(Boolean(PNewSubUser)),
    "role": Optional(Int(PUserRole)),
	"registrationId": Optional(Str(PRegistrationId))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := "";
logEventID := "CreateAccount.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

newUserRegistrationDetailUpdated := false;
accountCreated:= false;
brokerAccountOnboaradingClientTypeTMPCreated := false;

try
(
	PNewSubUser := PNewSubUser ?? false;
	PUserRole := PUserRole ?? -1;
	PRegistrationId := PRegistrationId ?? "";

    if(Global.RegexValidation(PEmail, "Email", "") == false) then 
    (
		Error("Email in not valid format.")
    );
     
    Code:= 0;
    if (!exists(Code:= Global.VerifyingNumbers[PEmail]) or Code >= 0) then 
    (
		Error("Email must be verified in order to create account");
    );

    if(Global.RegexValidation(PUserName, "UserName", "") == false) then 
    (
		Error("Username could only contain letters and numbers.");
    );
    if(PPassword != PRepeatedPassword) then
    (
        Error("Passwords does not match.");
    );

    if(Global.RegexValidation(PPassword, "Password", "") == false) then 
    (
        Error("Password must contain at least one uppercase, lowercase, special char and number, and must be at least 8 characters long.")
    );

    if(!System.String.IsNullOrWhiteSpace(select top 1 UserName from BrokerAccounts where UserName = PUserName)) then 
    (
        Error("Account with " + PUserName + " already exists");
    );
	
	if(PUserRole >= 0 && !POWRS.PaymentLink.Models.EnumHelper.IsEnumDefined(POWRS.PaymentLink.Models.AccountRole, PUserRole)) then 
	(
        Error("Role doesn't exists.");
	);
	if(PNewSubUser)then
	(
		commnet:= "While creating new sab user, looged used must be verified";
		SessionUser:= Global.ValidateAgentApiToken(true, false);
	);
	
	if(!PNewSubUser) then 
	(
		if(System.String.IsNullOrWhiteSpace(PRegistrationId))then
		(
			Error("RegistrationId parameter is mandatory");
		)
		else
		(
			newUserRegistrationDetail := 
				select top 1 * 
				from POWRS.PaymentLink.Models.NewUserRegistrationDetail 
				where Str(ObjectId) = Str(PRegistrationId);
				
			if(newUserRegistrationDetail = null)then
			(
				Error("RegistrationId doesn't exists.");
			)
			else if(!System.String.IsNullOrWhiteSpace(newUserRegistrationDetail.SuccessfullyRegisteredUserName)) then
			(
				Error("RegistrationId already used.");
			);
		);
	);

	logObject := PUserName;

    apiKey:= GetSetting("POWRS.PaymentLink.ApiKey", "");
    apiKeySecret:= GetSetting("POWRS.PaymentLink.ApiKeySecret", "");

    if(System.String.IsNullOrWhiteSpace(apiKey) or System.String.IsNullOrWhiteSpace(apiKeySecret)) then 
    (
        Error("Keys are missing");
    );
	
    Nonce:= Base64Encode(RandomBytes(32));
    S:= PUserName + ":" + Gateway.Domain + ":" + PEmail + ":" + PPassword + ":" + apiKey + ":" + Nonce;
    Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(apiKeySecret)));
    
    neuronDomain:= "https://" + Gateway.Domain;
    NewAccount:= POST(neuronDomain + "/Agent/Account/Create",
				{
					"apiKey": apiKey,
					"eMail": PEmail,
					"nonce": Nonce,
					"password": PPassword,
					"seconds": 1800,
					"signature": Signature,
					"userName": PUserName
				},
				{"Accept" : "application/json" });

    enabled:= Update BrokerAccounts set Enabled = true where UserName = PUserName;
    Global.VerifyingNumbers.Remove(PEmail);
	accountCreated := true;
	
	try
	(
		if(!exists(NewAccount.jwt)) then 
		(
			Error("Token not available in response.");
		);

		PLocalName:= "ed448";
		PNamespace:= "urn:ieee:iot:e2e:1.0";
		PKeyId:= NewGuid().ToString();
		KeyPassword:= Base64Encode(RandomBytes(20)).ToString();
		Nonce:= Base64Encode(RandomBytes(32)).ToString();

		S1:= PUserName + ":" + Gateway.Domain + ":" + PLocalName + ":" + PNamespace + ":" + PKeyId;
		KeySignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

		S2:= S1 + ":" + KeySignature + ":" + Nonce;
		RequestSignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

		NewKey:= POST(neuronDomain + "/Agent/Crypto/CreateKey",
				{
					"localName": PLocalName,
					"namespace": PNamespace,
					"id": PKeyId,
					"nonce": Nonce,
					"keySignature": KeySignature,
					"requestSignature": RequestSignature
				},
				{
					"Accept" : "application/json",
					"Authorization": "Bearer " + NewAccount.jwt
				});
		
		SetSetting(PUserName  + ".KeyId", PKeyId);
		SetSetting(PUserName  + ".KeySecret", KeyPassword);
	)
	catch
	(
		Log.Error("Unable to create key: " + Exception.Message, logObject, logActor, logEventID, null);
		Error("Unable to create key: " + Exception.Message);
	)
	finally
	(
		Destroy(Nonce);
		Destroy(S1);
		Destroy(KeySignature);
		Destroy(S2);
		Destroy(RequestSignature);
		Destroy(PKeyId);
		Destroy(KeySignature);
	);
	
	if(exists(newUserRegistrationDetail) and newUserRegistrationDetail != null)then
	(
		newUserRegistrationDetail.SuccessfullyRegisteredUserName := PUserName;
		Waher.Persistence.Database.Update(newUserRegistrationDetail);
		newUserRegistrationDetailUpdated := true;
	);
	
	creatorUserName := "";
	orgName := "";
	parentOrgName := "";
	enumNewUserRole := POWRS.PaymentLink.Models.AccountRole.User;
	try
	(
		if(exists(newUserRegistrationDetail) and newUserRegistrationDetail != null)then
		(
			creatorUserName := PUserName;
			orgName := newUserRegistrationDetail.NewOrgName;
			parentOrgName := newUserRegistrationDetail.ParentOrgName;
			enumNewUserRole := newUserRegistrationDetail.NewUserRole;
		)
		else
		(
			if(PUserRole >= 0 && PNewSubUser) then (
				enumNewUserRole := POWRS.PaymentLink.Models.EnumHelper.GetEnumByIndex(PUserRole);
			);
			
			try
			(	
				if(PNewSubUser) then (
					SessionUser:= Global.ValidateAgentApiToken(true, false);
					
					creatorUserName := SessionUser.username;
					creatorBrokerAccRole := 
						Select top 1 *
						from POWRS.PaymentLink.Models.BrokerAccountRole
						where UserName = creatorUserName;
					
					if(creatorBrokerAccRole != null) then (					
						if (creatorBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.SuperAdmin &&
							creatorBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.ClientAdmin
						) then (
							Error("Unable to create user. Logged user don't have appropriate role.");
						);
						
						if(enumNewUserRole < creatorBrokerAccRole.Role) then (
							Error("Unable to create user with higher privileges");
						);
						
						orgName := creatorBrokerAccRole.OrgName;
						parentOrgName := creatorBrokerAccRole.ParentOrgName;
					);			
				) else (
					enumNewUserRole := POWRS.PaymentLink.Models.AccountRole.ClientAdmin;
					creatorUserName := PUserName;
					orgName := ""; 
					parentOrgName := "Powrs";
				);			
			)
			catch
			(
				if(PNewSubUser) then(
					Error("Unable to create new sub user... " + Exception.Message);
				);
				
				enumNewUserRole := POWRS.PaymentLink.Models.AccountRole.ClientAdmin;
				creatorUserName := PUserName;
				orgName := ""; 
				parentOrgName := "Powrs";
			);
		);

		accountRole:= Create(POWRS.PaymentLink.Models.BrokerAccountRole);
		accountRole.UserName:= PUserName;
		accountRole.Role:= enumNewUserRole;
		accountRole.CreatorUserName:= creatorUserName;
		accountRole.OrgName:= orgName;
		accountRole.ParentOrgName:= parentOrgName;
		Waher.Persistence.Database.Insert(accountRole);
	)
	catch
	(
		Log.Error("Unable to create broker acc role: " + Exception.Message, logObject, logActor, logEventID, null);
		Error("Unable to create broker acc role: " + Exception.Message);
	);
	
	try
	(
		if(!PNewSubUser)then
		(
			brokerAccClientType := select top 1 * from POWRS.PaymentLink.ClientType.Models.BrokerAccountOnboaradingClientTypeTMP where UserName = PUserName;
			if(brokerAccClientType != null) then 
			(
				brokerAccClientType.OrgClientType := newUserRegistrationDetail.NewOrgClientType;
				Waher.Persistence.Database.Update(brokerAccClientType);
			)
			else
			(
				brokerAccClientType := Create(POWRS.PaymentLink.ClientType.Models.BrokerAccountOnboaradingClientTypeTMP);
				brokerAccClientType.UserName := PUserName;
				brokerAccClientType.OrgClientType := newUserRegistrationDetail.NewOrgClientType;
				Waher.Persistence.Database.Insert(brokerAccClientType);
			);
			brokerAccountOnboaradingClientTypeTMPCreated := true;
		);
	)
	catch
	(
		Log.Error("Unable to insert client type: " + Exception.Message, logObject, logActor, logEventID, null);
		Error(Exception.Message);
	);
	
	try
	(
		if(enumNewUserRole = POWRS.PaymentLink.Models.AccountRole.GroupAdmin and newUserRegistrationDetail != null)then
		(
			organizationClientType := Select top 1 * from POWRS.PaymentLink.ClientType.Models.OrganizationClientType where OrganizationName = newUserRegistrationDetail.NewOrgName;
			if(organizationClientType = null)then
			(
				organizationClientType := Create(POWRS.PaymentLink.ClientType.Models.OrganizationClientType);
				organizationClientType.OrganizationName := newUserRegistrationDetail.NewOrgName;
				organizationClientType.OrgClientType := newUserRegistrationDetail.NewOrgClientType;
				
				Waher.Persistence.Database.Insert(organizationClientType);
			);
		);
	)
	catch
	(
		Log.Error("Unable to insert organization name for GourpAdminUser: " + Exception.Message, logObject, logActor, logEventID, null);
		Error(Exception.Message);
	);
		
	try
	(
		MailBody := Create(System.Text.StringBuilder);
		MailBody.Append("Hello,");
		MailBody.Append("<br />");
		MailBody.Append("<br />New {{accountType}} created for PLG SRB. User name: <strong>{{userName}}</strong>. {{clientType}} Domain: <strong><i>{{domain}}</i></strong>");
		MailBody.Append("<br />");
		MailBody.Append("<br /><i>Best regards</i>");
		MailBody.Append("<br /><i>Vaulter</i>");
		
		MailBody := MailBody.Replace("{{userName}}", PUserName);
		MailBody := MailBody.Replace("{{domain}}", Gateway.Domain);
		
		if(PNewSubUser)then
		(
			MailBody := MailBody.Replace("{{accountType}}", "sub account");
			MailBody := MailBody.Replace("{{clientType}}", "");
		)
		else
		(
			MailBody := MailBody.Replace("{{clientType}}", "Client type: <strong>" +  newUserRegistrationDetail.NewOrgClientType.ToString() + "</strong>.");
			MailBody := MailBody.Replace("{{accountType}}", "account");
		);
		
		ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
		Config := ConfigClass.Instance;
		mailRecipients := GetSetting("POWRS.PaymentLink.OnBoardingSubmitMailList","");
		
		POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailRecipients, "Powrs Vaulter Create Acc", Str(MailBody), "", "");
			
		Destroy(MailBody);
	)
	catch
	(
		Log.Error("Unable to send email notification to Powrs support team" + Exception.Message, logObject, logActor, logEventID, null);
	);
	
	{
		"userName": PUserName,
		"jwt": NewAccount.jwt,
		"isApproved": false
	}
)
catch
(
    if(accountCreated) then 
    (
		try 
		(
			delete from BrokerAccounts where UserName = PUserName;
			delete from BrokerAccountRoles where UserName = PUserName;
		)
		catch
		(
			Log.Error("Unable to cleanup for user " + PUserName, logObject, logActor, logEventID, null);
		);
    );
    
	if(newUserRegistrationDetailUpdated) then
	(
		try 
		(
			newUserRegistrationDetail.SuccessfullyRegisteredUserName := "";
			Waher.Persistence.Database.Update(newUserRegistrationDetail);
		)
		catch
		(
			Log.Error("Unable to cleanup 'newUserRegistrationDetail' for userName " + PUserName + ", and newUserRegistrationDetail.ObjectId: " + newUserRegistrationDetail.ObjectId, logObject, logActor, logEventID, null);
		);
	);
	
	if(brokerAccountOnboaradingClientTypeTMPCreated) then
	(
		try 
		(
			delete from BrokerAccountOnboaradingClientTypeTMPs where UserName = PUserName;
		)
		catch
		(
			Log.Error("Unable to cleanup 'BrokerAccountOnboaradingClientTypeTMPs' for userName " + PUserName, logObject, logActor, logEventID, null);
		);
	);
	
	Log.Error("Unable to create user: " + Exception.Message, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
)
finally
(
    Destroy(Nonce);
    Destroy(S);
    Destroy(Signature);
	Destroy(newUserRegistrationDetail);
);