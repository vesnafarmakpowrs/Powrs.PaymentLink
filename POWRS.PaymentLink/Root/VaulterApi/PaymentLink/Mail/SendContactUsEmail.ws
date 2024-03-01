Response.SetHeader("Access-Control-Allow-Origin","*");

({
   "userEmail":Required(String(PUserEmail)),
   "body":Required(String(PBody))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
 numberOfEmailSent:= 0;
 remoteEndpoint:= Request.RemoteEndPoint.Split(':', null)[0];
 if(exists(Global.ContactUsEmailSent[remoteEndpoint])) then 
 (
     numberOfEmailSent:= Global.ContactUsEmailSent[remoteEndpoint];
     if(numberOfEmailSent >= 3) then 
     (
        Error("Contact us email already sent. Three email per hour is allowed.");
     );
 );

 ContactEmail := GetSetting("POWRS.PaymentLink.ContactEmail","");  
 htmlTemplatePath:= Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\EN\\ContactUs.html";

 if (!File.Exists(htmlTemplatePath)) then
    Error("Template path does not exist");

 html:= System.IO.File.ReadAllText(htmlTemplatePath);
 html := html.Replace("{UserName}",PUserEmail);
 html := html.Replace("{UserEmail}", PUserEmail);
 html := html.Replace("{Comment}", PBody);

 ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
 Config := ConfigClass.Instance;
 POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, ContactEmail, "PLG Contact ", html, null, null);

 if(!exists(Global.ContactUsEmailSent)) then 
 (
    Global.ContactUsEmailSent:= Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));
 );

 Global.ContactUsEmailSent[remoteEndpoint]:= numberOfEmailSent + 1;

{    	
    "Success": true
}

)
catch
(
 Log.Error(Exception, null);
 BadRequest(Exception.Message);
);