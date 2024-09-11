Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword)),
    "repeatedPassword":Required(Str(PRepeatedPassword)),
    "email" : Required(Str(PEmail)),
	"newSubUser": Optional(Boolean(PNewSubUser)),
    "role": Optional(Int(PUserRole))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := "";
logEventID := "CreateAccount.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    if(PEmail not like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}") then 
    (
		Error("Email in not valid format.")
    );
     
    Code:= 0;
    if (!exists(Code:= Global.VerifyingNumbers[PEmail]) or Code >= 0) then 
    (
		Error("Email must be verified in order to create account");
    );

    if(PUserName not like "^[\\p{L}\\p{N}]{8,20}$") then 
    (
		Error("Username could only contain letters and numbers.");
    );
    if(PPassword != PRepeatedPassword) then
    (
        Error("Passwords does not match.");
    );

    if(PPassword not like "^(?=.*[\\p{Ll}])(?=.*[\\p{Lu}])(?=.*[\\p{N}])(?=.*[^\\p{L}\\p{N}])[^\\s]{8,}$") then 
    (
        Error("Password must contain at least one uppercase, lowercase, special char and number, and must be at least 8 characters long.")
    );

    if(!System.String.IsNullOrWhiteSpace(select top 1 UserName from BrokerAccounts where UserName = PUserName)) then 
    (
        AccountAlreadyExists:= true;
        Error("Account with " + PUserName + " already exists");
    );
	
	PNewSubUser := PNewSubUser ?? false;
	PUserRole := PUserRole ?? -1;
	
	if(PUserRole >= 0 && !POWRS.PaymentLink.Models.EnumHelper.IsEnumDefined(POWRS.PaymentLink.Models.AccountRole, PUserRole)) then (
        Error("Role doesn't exists.");
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
		
		Log.Informational("Create account -> cripted keys created", logObject, logActor, logEventID, null);
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
	
	try
	(
		MailBody := Create(System.Text.StringBuilder);
		MailBody.Append("Hello,");
		MailBody.Append("<br />");
		MailBody.Append("<br />New account created for PLG. User name: <strong>" + PUserName + " </strong>.");
		MailBody.Append("<br />");
		MailBody.Append("<br /><i>Best regards</i>");
		MailBody.Append("<br /><i>Vaulter</i>");
		
		ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
		Config := ConfigClass.Instance;
		mailRecipients := GetSetting("POWRS.PaymentLink.OnBoardingSubmitMailList","");
		
		POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailRecipients, "Powrs Vaulter Create Acc", MailBody, null, null);
					
		destroy(MailBody);
	)
	catch
	(
		Log.Error("Unable to send email notification to Powrs support team" + Exception.Message, logObject, logActor, logEventID, null);
	);
	
	try
	(
		creatorUserName := "";
		orgName := "";
		parentOrgName := "";
		
		enumNewUserRole := POWRS.PaymentLink.Models.AccountRole.User;
		
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
				Error("Unable to create new user... " + Exception.Message);
			);
			
			enumNewUserRole := POWRS.PaymentLink.Models.AccountRole.ClientAdmin;
			creatorUserName := PUserName;
			orgName := ""; 
			parentOrgName := "Powrs";
		);			

		accountRole:= Create(POWRS.PaymentLink.Models.BrokerAccountRole);
		accountRole.UserName:= PUserName;
		accountRole.Role:= enumNewUserRole;
		accountRole.CreatorUserName:= creatorUserName;
		accountRole.OrgName:= orgName;
		accountRole.ParentOrgName:= parentOrgName;

		Waher.Persistence.Database.Insert(accountRole);
		
		Log.Informational("Create account -> broker acc roles inserted for user name: " + PUserName, logObject, logActor, logEventID, null);
	)
	catch
	(
		Log.Error("Unable to create broker acc role: " + Exception.Message, logObject, logActor, logEventID, null);
		Error("Unable to create  broker acc role: " + Exception.Message);
	);
		
	{
		"userName": PUserName,
		"jwt": NewAccount.jwt,
		"isApproved": false
	}
)
catch
(
    if(!exists(AccountAlreadyExists)) then 
    (
		try 
		(
			delete from BrokerAccounts where UserName = PUserName;
		)
		catch
		(
			Log.Error("Unable to cleanup for user " + PUserName, logObject, logActor, logEventID, null);
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
);