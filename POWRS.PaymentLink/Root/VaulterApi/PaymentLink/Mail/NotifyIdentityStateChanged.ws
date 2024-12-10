AuthenticateSession(Request,"User");
Authorize(User,"Admin.Notarius.NeuroFeatures");

if !exists(Posted) then BadRequest("No data posted.");
if !exists(Posted.id) or !exists(Posted.state) then BadRequest("No data posted.");

success:= true;
try
(
if(Posted.state == "Approved") then
(
identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Id = Str(Posted.id);

if(identity == null) then
(
	Error("Identity not found");
);

foreach prop in identity.Properties do 
(
 if(prop.Name == "FIRST") then
(
 firstName:= prop.Value;
)
else if(prop.Name == "LAST") then 
(
lastName:= prop.Value;
)
else if(prop.Name == "AGENT") then 
(
 agentName:= prop.Value;
)
else if(prop.Name == "EMAIL") then 
(
 email:= prop.Value;
)
else if(prop.Name == "COUNTRY") then 
(
 country:= prop.Value;
);						
);

if(exists(firstName) and exists(lastName) and exists(agentName) and exists(email) and exists(country)) then
(
 if(agentName.Contains("VaulterApi/PaymentLink/Account/CreateAccount.ws")) then
(
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = identity.Account;
	if(generalInfo != null and generalInfo.DateApproved = null)then
	(
		generalInfo.DateApproved := Now;
		Waher.Persistence.Database.Update(generalInfo);
	);
	
    path:= Waher.IoTGateway.Gateway.RootFolder + "\\payout\\HtmlTemplates\\" + country + "\\ApprovedLegalIdentity.html";
	if(!System.IO.File.Exists(path)) then 
	(
      path:= Waher.IoTGateway.Gateway.RootFolder + "\\payout\\HtmlTemplates\\EN\\ApprovedLegalIdentity.html";	  
 	  if(!System.IO.File.Exists(Waher.IoTGateway.Gateway.RootFolder + "\\payout\\HtmlTemplates\\EN\\ApprovedLegalIdentity.html")) then 
      (
		Error("Template not found")
	  );
    );
	
    html:= System.IO.File.ReadAllText(path);        
	html:= html.Replace("{FIRST}", firstName);
	html:= html.Replace("{LAST}", firstName);
	html:= html.Replace("{YEAR}", Str(Year(Now)));

	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, email, "Vaulter Identity state changed", html, "", "");	
);
);
);
)
catch
(
   BadRequest(Exception.Message);
   success:= false;
);

{
 "success": success
}
