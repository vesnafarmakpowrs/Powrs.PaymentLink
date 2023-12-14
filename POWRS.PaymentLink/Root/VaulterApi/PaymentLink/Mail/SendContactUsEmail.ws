Response.SetHeader("Access-Control-Allow-Origin","*");

({
   "userEmail":Required(String(PUserEmail)),
   "body":Required(String(PBody))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
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
 POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, ContactEmail, "PLG Contact ", html, null, null);

{    	
    "Success": true
}

)
catch
(
 Log.Error(Exception, null);
 BadRequest(Exception.Message);
);