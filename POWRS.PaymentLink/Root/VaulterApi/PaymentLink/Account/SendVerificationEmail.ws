Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "email":Required(String(PEmail)),
    "countryCode":Required(String(PCountryCode))    
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
    if( Global.RegexValidation(PEmail, "Email", "") == false or
		Global.RegexValidation(PCountryCode, "CountryCode", "") == false
	) then
	(
		Error("Payload does not conform to specification.");
	);

    portal := "paylink." + After(domain,"neuron.");
    remoteEndpoint:= Split(Request.RemoteEndPoint, ":")[0];

    if !exists(Global.VerifyingEmailIP) then 
    (
        Global.VerifyingEmailIP :=Create(Waher.Runtime.Cache.Cache,System.String,System.Int32,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));
    );
    
    if !exists(Global.VerifyingNumbers) then 
    (
        Global.VerifyingNumbers:=Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));
    );
    
    message := "";
    value := 0;
    maxAttemptsInHour := 10;
    
    Global.VerifyingEmailIP.TryGetValue(remoteEndpoint , value);
    
    if value > 0 then value := value + 1;
    
    if value > maxAttemptsInHour then 
    (
        Error('Too many attempts. Try again in a hour.')
    )  
    else 
    (
        Global.VerifyingEmailIP.Add(remoteEndpoint, value);
    );
    	
    VerificationCode:=100000+Floor(Uniform(0,899999.9999999999999999));
    
    Global.VerifyingNumbers.Add(PEmail,VerificationCode);
    
    PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");
    htmlTemplateRoot := Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\";

    if(!System.IO.Directory.Exists(htmlTemplateRoot)) then 
    (
        htmlTemplateRoot:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\EN\\";
    );

    htmlTemplatePath:= htmlTemplateRoot +  + "VerifyEmail.html";
    html:= System.IO.File.ReadAllText(htmlTemplatePath);
    
    html := Replace(html,"{{Code}}",VerificationCode);
    html := Replace(html,"{{Year}}", Str(Year(Now)));
    
    Log.Informational("Sending email for verification email:" + PEmail,null);
    ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
    Config := ConfigClass.Instance;
    POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, PEmail, "Vaulter", html, null, null);
    
    {
      "Status":true
    }
)
catch
(
     Log.Error(Exception, null);
     BadRequest(Exception.Message);
);