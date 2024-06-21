SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"Link":Required(String(PLink)),
	"PhoneNumber": Optional(String(PPhoneNumber))
}:=Posted) ??? BadRequest(Exception.Message);

try
(
	linkParts := Split(PLink, "?ID=");
	if(count(linkParts) < 2) then 
	(
		BadRequest("Input link not valid...");
	);

	contractId := Global.DecodeContractId(linkParts[1]);
	
	tokenObj :=
		select top 1 * 
		from IoTBroker.NeuroFeatures.Token t
		where OwnershipContract = contractId;

	if(tokenObj == null) then 
	(
		BadRequest("Input link not valid...");
	);

	variables := tokenObj.GetCurrentStateVariables();
	
	if(exists(PPhoneNumber)) then 
	(
		if(PPhoneNumber not like "^[+]?[0-9]{6,15}$") then 
		(
			Error("Phone number invalid");
		);
		buyerPhoneNumber:= PPhoneNumber;
	)
	else 
	(
		buyerPhoneNumber:= select top 1 Value from variables.VariableValues where Name = "BuyerPhoneNumber";
	);
	
	sellerName:= select top 1 Value from variables.VariableValues where Name = "SellerName";
	country:= select top 1 Value from variables.VariableValues where Name = "Country";
	
	buyerPhoneNumber ?? Error("Phone number could not be empty.");
	sellerName ?? Error("Seller name could not be empty.");
	country:= country ?? "RS";

	translation:= " is sending Vaulter payment link: ";
	if(country == "RS") then 
	(
		translation:= " šalje Vaulter link za plaćanje: ";
	);
	
	ApiKey := GetSetting("POWRS.PaymentLink.SMSTextLocalKey","");	
	SMSBody := sellerName + translation + PLink;
	
	Form := Create(System.Collections.Generic.Dictionary,System.String,System.String);
	Form["apikey"] := ApiKey;
	Form["numbers"] := buyerPhoneNumber;
	Form["sender"] := "Vaulter";
	Form["message"] := SMSBody;
	Post("https://api.txtlocal.com/send/", Form);

	addNoteEndpoint:= Gateway.GetUrl("/AddNote/" + tokenObj.TokenId);
	namespace:= Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd");
	Post(addNoteEndpoint ,<SMSToBuyerSent xmlns=namespace phoneNumber=buyerPhoneNumber  />,{},Waher.IoTGateway.Gateway.Certificate);
		
	"Success";
)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
