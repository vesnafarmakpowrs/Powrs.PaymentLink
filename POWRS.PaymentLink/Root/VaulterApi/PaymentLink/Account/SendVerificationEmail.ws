({
    "email":Optional(String(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "countryCode":Required(String(PCountryCode)  like "[A-Z]{2}")    
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

portal := "paylink." + After(domain,"neuron.");

if !exists(Global.VerifyingNumbers) then
	Global.VerifyingNumbers:=Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));

VerificationCode:=100000+Floor(Uniform(0,899999.9999999999999999));

Global.VerifyingNumbers.Add(PEmail,VerificationCode);

htmlTemplateRoot := Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + PCountryCode + "\\";
htmlTemplatePath:= htmlTemplateRoot +  + "VerifyEmail.html";
html:= System.IO.File.ReadAllText(htmlTemplatePath);

html := Replace(html,"{{Code}}",VerificationCode);
html := Replace(html,"{{Portal}}",portal);

Log.Informational("Sending email for verification email:" + PEmail,null);
ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
Config := ConfigClass.Instance;
POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, PEmail, "Vaulter", html, null, null);


{
  "Status":true,
  "VerificationCode":VerificationCode
}