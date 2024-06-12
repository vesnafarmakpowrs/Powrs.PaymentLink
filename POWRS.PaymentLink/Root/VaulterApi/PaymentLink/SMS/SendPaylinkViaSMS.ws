SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"Link":Required(String(PLink))
}:=Posted) ??? BadRequest(Exception.Message);

try
(	
	contractId := "";
	buyerPhoneNumber := "";
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
		if(variable != null && variable.Name == "BuyerPhoneNumber") then 
		(
			buyerPhoneNumber := variable.Value ?? "";
		);
		
		if(variable != null && variable.Name == "SellerName") then 
		(
			sellerName := variable.Value ?? "";
		);
		
	);
	
	buyerPhoneNumber := buyerPhoneNumber ?? "";
	sellerName := sellerName ?? "";
	
	if(buyerPhoneNumber == "") then
	(
		BadRequest("Buyer mobile number not found...");
	);
		
	ApiKey := GetSetting("POWRS.PaymentLink.SMSTextLocalKey","");	

	SMSBody := sellerName + " salje link za placanje: " + PLink;
	
	Form := Create(System.Collections.Generic.Dictionary,System.String,System.String);
	Form["apikey"] := ApiKey;
	Form["numbers"] := buyerPhoneNumber;
	Form["sender"] := "Vaulter";
	Form["message"] := SMSBody;
	Post("https://api.txtlocal.com/send/", Form);

	addNoteEndpoint:="https://" + Gateway.Domain + "/AddNote/" + tokenObj.TokenId;
	namespace:= "https://" + Gateway.Domain + "/Downloads/EscrowPaylinkRS.xsd";
	Post(addNoteEndpoint ,<SMSCounterUpdate xmlns=namespace  />,{},Waher.IoTGateway.Gateway.Certificate);

		
	"Success";
)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
