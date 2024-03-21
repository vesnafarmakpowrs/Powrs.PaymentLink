Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "userName":Required(String(PUserName) like "^[\\p{L}\\p{N}]{8,20}$")
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(	
	user:= select top 1 * from BrokerAccounts where UserName = PUserName;
	if(user == null) then 
	(
		Error("User does not exists");
	);

	if(!exists(Global.PasswordResetRequests)) then
	(
		Global.PasswordResetRequests := Create(Waher.Runtime.Cache.Cache,CaseInsensitiveString,System.Object,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(24));
	);

	passwordResetRequest:= null;
	if(Global.PasswordResetRequests.TryGetValue(PUserName, passwordResetRequest)) then
	(
		Error("Reset password can only be initiated once a day");
	);

	Properties:= select top 1 Properties from IoTBroker.Legal.Identity.LegalIdentity where Account = PUserName and State = "Approved" order by Created desc;

	if(Properties == null) then 
	(
		Error("Unable to request password reset for this user");
	);

	Email:= select top 1 Value from Properties where Name = "EMAIL";
	Country:= select top 1 Value from Properties where Name = "COUNTRY";

	if(System.String.IsNullOrEmpty(Email) or System.String.IsNullOrEmpty(Country)) then
	(
		Error("Unable to send code. Email does not exists.");
	);

	VerificationCode:=100000+Floor(Uniform(0,899999.9999999999999999));
	passwordResetRequest:= {
		"VerificationCode": VerificationCode,
		"ValidUntil": NowUtc.AddMinutes(15)
	};

	Global.PasswordResetRequests.Add(PUserName, passwordResetRequest);
	
	htmlTemplatePath := Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + Country + "\\VerifyEmail.html";

    if(!System.IO.Directory.Exists(htmlTemplatePath)) then 
    (
        htmlTemplatePath:= Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\EN\\VerifyEmail.html";
    );

    html:= System.IO.File.ReadAllText(htmlTemplatePath);
    
    html := Replace(html,"{{Code}}",VerificationCode);
    html := Replace(html,"{{Portal}}","paylink." + After(domain,"neuron."));

	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
    Config := ConfigClass.Instance;

    POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, Email, "Vaulter Password Reset", html, null, null);
	
	{
	}
)
catch
(
	BadRequest(Exception.Message)
	Log.Error(Exception.Message, null);
);