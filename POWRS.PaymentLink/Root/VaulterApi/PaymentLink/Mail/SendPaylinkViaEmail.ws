SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"Link":Required(String(PLink)),
	"Email": Optional(String(PEmail))
}:=Posted) ??? BadRequest(Exception.Message);

try
(
	linkParts:= Split(PLink, "?ID=");
	if(count(linkParts) < 2) then 
	(
		Error("Input link not valid...");
	);

	contractId:= Global.DecodeContractId(linkParts[1]);
	
	tokenObj:=
		select top 1 * 
		from IoTBroker.NeuroFeatures.Token t
		where OwnershipContract = contractId;

	if(tokenObj == null) then 
	(
		Error("Input link not valid...");
	);

	variables := tokenObj.GetCurrentStateVariables();
	
	if(variables.State != "AwaitingForPayment") then 
	(
		Error("Link is no longer valid");
	);

	if(exists(PEmail)) then 
	(
		if(Global.RegexValidation(PEmail, "Email", "") == false) then 
		(
			Error("Email not valid");
		);

		buyerEmail:= PEmail;
	)
	else
	(
		buyerEmail:= select top 1 Value from variables.VariableValues where Name = "BuyerEmail";
	);
	
	buyerName:= select top 1 Value from variables.VariableValues where Name = "Buyer";
	sellerName:= select top 1 Value from variables.VariableValues where Name = "SellerName";
	country:= select top 1 Value from variables.VariableValues where Name = "Country";
	
	buyerEmail ?? Error("Buyer email could not be empty.");
	buyerName ?? Error("Buyer name could not be empty.");
	sellerName ?? Error("Seller name could not be empty.");
	country:= country ?? "RS";
	
	mailTemplateUrl:= Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + country + "\\SendLinkViaEmail.html";
	if (!File.Exists(mailTemplateUrl)) then
	(
		Error("Template path does not exist");
	);

	MailBody:= System.IO.File.ReadAllText(mailTemplateUrl);
	MailBody := MailBody.Replace("{{buyerName}}",buyerName);
	MailBody := MailBody.Replace("{{sellerName}}", sellerName);
	MailBody := MailBody.Replace("{{link}}", PLink);
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, buyerEmail, "Vaulter", MailBody, null, null);
	
	addNoteEndpoint:= Gateway.GetUrl(":8088/AddNote/" + tokenObj.TokenId);
	namespace:= Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd");
	Post(addNoteEndpoint,<EmailToBuyerSent xmlns=Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd") email=buyerEmail />,{},Gateway.Certificate);

	"Success";
)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
