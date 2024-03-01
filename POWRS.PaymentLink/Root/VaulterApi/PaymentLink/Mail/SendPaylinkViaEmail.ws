SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"Link":Required(String(PLink))
}:=Posted) ??? BadRequest(Exception.Message);

try
(	
	contractId := "";
	buyerEmail := "";	
	buyerName := "";
	sellerName := "";

	linkParts := Split(PLink, "?ID=");
	if(count(linkParts) > 1) then 
	(
		contractId := Global.DecodeContractId(linkParts[1]) ;
	)
	else 
	(
		BadRequest("Input link not valid...");
	);
	
	tokenObj :=
		select top 1 * 
		from IoTBroker.NeuroFeatures.Token t
		where OwnershipContract = contractId;

	if(tokenObj == null) then 
	(
		BadRequest("Input link not valid...");
	);

	variables := tokenObj.GetCurrentStateVariables();
	
	foreach variable in variables.VariableValues do
	(
		if(variable != null && variable.Name == "BuyerEmail") then 
		(
			buyerEmail := variable.Value ?? "";
		);
		
		if(variable != null && variable.Name == "Buyer") then 
		(
			buyerName := variable.Value ?? "";
		);
		
		
		if(variable != null && variable.Name == "SellerName") then 
		(
			sellerName := variable.Value ?? "";
		);
		
	);
	
	buyerEmail := buyerEmail ?? "";
	buyerName := buyerName ?? "";
	sellerName := sellerName ?? "";
	
	if(buyerEmail == "") then
	(
		BadRequest("Buyer email not found...");
	);
	
	MailBody := 
		"Dear {{buyerName}},"
		+ "<br />"
		+ "<br /><strong>{{PKupac}}</strong> has created a Vaulter payment link for you. Click on the following &nbsp"
		+ "<a href = '{{PLink}}'>LINK</a>"
		+ "&nbsp to proceed with the payment."
		+ "<br /><br />Best regards,"
		+ "<br />Vaulter"
		;
	
	MailBody := Replace(MailBody, "{{buyerName}}", buyerName);
	MailBody := Replace(MailBody, "{{PKupac}}", sellerName);
	MailBody := Replace(MailBody, "{{PLink}}", PLink);
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, buyerEmail, "Vaulter", MailBody, "", "");
		
	"Success";
)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
