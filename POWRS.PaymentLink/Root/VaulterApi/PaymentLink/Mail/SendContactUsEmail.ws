({
   "userEmail":Required(String(PUserEmail)),
   "body":Required(String(PBody))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Response.SetHeader("Access-Control-Allow-Origin","*");
success := false;

ContactEmail := GetSetting("POWRS.PaymentLink.ContactEmail","");

 htmlTemplatePath:= Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\EN\\ContactUs.html";
 html:= System.IO.File.ReadAllText(htmlTemplatePath);
 html := html.Replace("{UserName}",auth.userName);
 html := html.Replace("{UserEmail}", PUserEmail);
 html := html.Replace("{Comment}", PBody);

 ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
 Config := ConfigClass.Instance;
 POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, ContactEmail, "PLG Contact ", html);
 success := true;
{    	
    "Success": success
}