({
    "subUserName":Required(Str(PSubUserName))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, false);
logObject := SessionUser.username;
logEventID := "DeactivateUser.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try(
	if(PSubUserName not like "^[\\p{L}\\p{N}]{8,20}$") then 
    (
		Error("subUsername could only contain letters and numbers.");
    );
	
	if(System.String.IsNullOrWhiteSpace(select top 1 UserName from BrokerAccounts where UserName = PSubUserName)) then 
    (
        Error("Account don't exists");
    );

	if(!System.String.IsNullOrWhiteSpace(select top 1 UserName from BrokerAccounts where UserName = PSubUserName and Enabled = false)) then 
    (
        Error("Account already deactivated");
    );

	sesnUsrBrokerAccRole := 
		Select top 1 *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = SessionUser.username;
		
	if (sesnUsrBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.ClientAdmin) then (
		Error("Unable to process request. Logged user don't have appropriate role.");
	);

	sesnUsrIdentity := 
		select top 1 * 
		from IoTBroker.Legal.Identity.LegalIdentity 
		where Account = SessionUser.username
			And State = "Approved";
	
	if(sesnUsrIdentity == null) then (
		Error("Unable to process request. Logged user don't have approved legal identity.");
	);
	
	subUsrIdentity := 
		select top 1 * 
		from IoTBroker.Legal.Identity.LegalIdentity 
		where Account = PSubUserName
			And State = "Approved";
	
	if(subUsrIdentity == null) then (
		Error("Unable to process request. Sub user don't have approved legal identity.");
	);	
	
	subUsrBrokerAccRole := 
		Select top 1 *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = PSubUserName;
		
	if (subUsrBrokerAccRole.Role == null) then (
		Error("Unable to process request. Sub user don't found.");
	);
	
	if (sesnUsrBrokerAccRole.OrgName != subUsrBrokerAccRole.OrgName) then (
		Error("Unable to process request. You can't request deactivation of this user.");
	);
			
    Update BrokerAccounts set Enabled = false where UserName = PSubUserName;
	XmppServerModule.PersistenceLayer.AccountUpdated(PSubUserName);
	
	MailBody := Create(System.Text.StringBuilder);
	MailBody.Append("Hello,");
	MailBody.Append("<br />");
	MailBody.Append("<br />Request to deactivate Legal identity on domen: {{domen}} :");
	MailBody.Append("<br />");
	MailBody.Append("<br /><strong>User to be deactivated:</strong>");
	MailBody.Append("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Username:</strong> {{subUserName}}");
	MailBody.Append("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Name:</strong> {{subFirstLast}}");
	MailBody.Append("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Email:</strong> {{subUserEmail}}");
	MailBody.Append("<br />");
	MailBody.Append("<br /><strong>Requested by client admin:</strong>");
	MailBody.Append("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Username:</strong> {{clientUserName}}");
	MailBody.Append("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Name:</strong> {{clientFirstLast}}");
	MailBody.Append("<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>Email:</strong> {{clientUserEmail}}");
	MailBody.Append("<br />");
	MailBody.Append("<br />Please review this request.");
	MailBody.Append("<br />");
	MailBody.Append("<br />Best regards,");
	MailBody.Append("<br />Vaulter");
		
	clientUserName := sesnUsrIdentity.Account;
	clientFirstLast := "";
	clientUserEmail := "";	
	subUserName := subUsrIdentity.Account;
	subFirstLast := "";
	subUserEmail := "";
	
	foreach item in sesnUsrIdentity.Properties do (
		if(item.Name == "FIRST") then (
			clientFirstLast := item.Value;
		) else if (item.Name == "LAST") then (
			clientFirstLast += " " +item.Value;
		) else if (item.Name == "EMAIL") then (
			clientUserEmail := item.Value;
		);
	);
	
	foreach item in subUsrIdentity.Properties do (
		if(item.Name == "FIRST") then (
			subFirstLast := item.Value;
		) else if (item.Name == "LAST") then (
			subFirstLast += " " +item.Value;
		) else if (item.Name == "EMAIL") then (
			subUserEmail := item.Value;
		);
	);
	
	MailBody := Replace(MailBody, "{{clientUserName}}", clientUserName);
	MailBody := Replace(MailBody, "{{clientFirstLast}}", clientFirstLast);
	MailBody := Replace(MailBody, "{{clientUserEmail}}", clientUserEmail);
	MailBody := Replace(MailBody, "{{subUserName}}", subUserName);
	MailBody := Replace(MailBody, "{{subFirstLast}}", subFirstLast);
	MailBody := Replace(MailBody, "{{subUserEmail}}", subUserEmail);
	MailBody := Replace(MailBody, "{{domen}}", Gateway.Domain);
	
	mailReceivers := GetSetting("POWRS.PaymentLink.LIStatusContactEmail","");
	if(System.String.IsNullOrWhiteSpace(mailReceivers)) then 
	(
		Error("User deactivated. Setting mailReceivers empty...");
	);
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailReceivers, "PLGenerator - Disable identity", MailBody, null, null);	

	Log.Informational("Succeffully deactivated user: " + subUserName, logObject, logActor, logEventID, null);
				
	x:= "ok";
)
catch(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
    BadRequest("Unable to process request. Error: " + Exception.Message);	
);