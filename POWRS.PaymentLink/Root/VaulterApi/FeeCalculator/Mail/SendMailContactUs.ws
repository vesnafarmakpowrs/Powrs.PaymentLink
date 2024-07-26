SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "SendMailContactUs.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

({
   "message":Required(String(PMessage)),
   "organizationNumber":Required(String(POrganizationNumber))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
	numberOfEmailSent:= 0;
	remoteEndpoint:= Split(Request.RemoteEndPoint, ":")[0];
	if(exists(Global.ContactUsEmailSent[remoteEndpoint])) then 
	(
		numberOfEmailSent:= Global.ContactUsEmailSent[remoteEndpoint];
		if(numberOfEmailSent >= 3) then 
		(
			Error("Contact us email already sent. Three email per hour is allowed.");
		);
	);
	
	feeCalcObj := select top 1 * from POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator where OrganizationNumber = POrganizationNumber;
	if(feeCalcObj == null) then 
	(
		Error("OrganizationNumber don't exists in db");
	);

	MailBody := Create(System.Text.StringBuilder);
	MailBody.Append("Hello,");
	MailBody.Append("<br />");
	MailBody.Append("<br />A user <strong>{{user}}</strong> is requesting your help.");
	MailBody.Append("<br />");
	MailBody.Append("<br />Message:");
	MailBody.Append("<br />{{message}}");
	MailBody.Append("<br />");
	MailBody.Append("<br />Customer details:");
	MailBody.Append("<br />Company name: <strong>{{CompanyName}}</strong>");
	MailBody.Append("<br />Org number: <strong>{{OrganizationNumber}}</strong>");
	MailBody.Append("<br />Contact person: <strong>{{ContactPerson}}</strong>");
	MailBody.Append("<br />Contac email: <strong>{{ContactEmail}}</strong>");
	MailBody.Append("<br />");
	MailBody.Append("<br />Best regards");
	MailBody.Append("<br />Vaulter Fee Calculator");
	
	MailBody := Replace(MailBody, "{{user}}", SessionUser.username);
	MailBody := Replace(MailBody, "{{message}}", PMessage);
	MailBody := Replace(MailBody, "{{CompanyName}}", feeCalcObj.CompanyName);
	MailBody := Replace(MailBody, "{{OrganizationNumber}}", feeCalcObj.OrganizationNumber);
	MailBody := Replace(MailBody, "{{ContactPerson}}", feeCalcObj.ContactPerson);
	MailBody := Replace(MailBody, "{{ContactEmail}}", feeCalcObj.ContactEmail);
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	mailRecipients := GetSetting("POWRS.PaymentLink.FeeCalculatorSupportEmail","");
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailRecipients, "Vaulter Fee Calculator", MailBody, null, null);
		
	destroy(MailBody);
	if(!exists(Global.ContactUsEmailSent)) then 
	(
		Global.ContactUsEmailSent:= Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));
	);
	Global.ContactUsEmailSent[remoteEndpoint]:= numberOfEmailSent + 1;
	Log.Informational("Successfully send email to customer support mail list.", logObject, logActor, logEventID, null);

	{    	
		"success": true
	}
)
catch
(
	Log.Error("Unable to send mail: " + Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);