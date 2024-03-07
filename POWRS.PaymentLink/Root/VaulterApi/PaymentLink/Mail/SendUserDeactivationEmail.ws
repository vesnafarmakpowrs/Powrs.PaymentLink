SessionUser:= Global.ValidateAgentApiToken(true, false);

({
    "subUserName":Required(Str(PSubUserName))
}:=Posted) ??? BadRequest(Exception.Message);

try(
	sesnUsrBrokerAccRole := 
		Select top 1 *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = SessionUser.username;
		
	if (sesnUsrBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.Client) then (
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
			
	MailBody := 
		"Request to disable Legal identity: "
		+ "<br />"
		+ "<br /><strong>Client:</strong> {{emailClient}}"
		+ "<br /><strong>User to be disabled:</strong> {{emailSubUser}}"
		+ "<br />"
		+ "<br />Vaulter"
	;
	
	emailClient := sesnUsrIdentity.Account + ", ";
	foreach item in sesnUsrIdentity.Properties do (
		if(item.Name == "FIRST" || item.Name == "LAST") then (
			emailClient += " " + item.Value;
		)else if (item.Name == "EMAIL") then (
			emailClient += ", <strong>email:</strong>  " + item.Value;
		);
	);
	
	emailSubUser := subUsrIdentity.Account + ", ";
	foreach item in subUsrIdentity.Properties do (
		if(item.Name == "FIRST" || item.Name == "LAST") then (
			emailSubUser += " " + item.Value;
		)else if (item.Name == "EMAIL") then (
			emailSubUser += ", <strong>email:</strong>  " + item.Value;
		);
	);
	
	MailBody := Replace(MailBody, "{{emailClient}}", emailClient);
	MailBody := Replace(MailBody, "{{emailSubUser}}", emailSubUser);
	
	mailReceivers := GetSetting("POWRS.PaymentLink.LIStatusContactEmail","");
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailReceivers, "PLGenerator - Disable identity", MailBody, null, null);	
			
	x:= "ok";
)
catch(
	Log.Error("Unable to process request. Error: " + Exception.Message, "", "SendUserDeactivationMail", null);
    BadRequest(Exception.Message);	
);