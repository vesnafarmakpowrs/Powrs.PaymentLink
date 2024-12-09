SessionToken:=  Global.ValidatePayoutJWT();

({
    "isFromMobile":Required(Bool(PIsFromMobile)),
	"tabId": Required(Str(PTabId)),
	"timeZoneOffset": Required(Num(PTimeZoneOffset))
}:=Posted) ??? BadRequest(Exception.Message);
try
(
    responseObject:= {"Success": true, "Response": null, "Message": System.String.Empty};
	if(!exists(POWRS.Payment.PaySpot.PayspotService)) then 
	(
		Error("Not configured");
	);

	IpsOnly:= false;

	if(exists(SessionToken.Claims.ipsOnly)) then 
	(
		IpsOnly:=  SessionToken.Claims.ipsOnly
	);

	ContractId:= SessionToken.Claims.contractId;
	TokenId:= SessionToken.Claims.tokenId;
	
	token:= select top 1 * from IoTBroker.NeuroFeatures.Token t where t.TokenId = TokenId;
	if(token == null) then
	(
		BadRequest("Token does not exists");
	);

	currentState:= token.GetCurrentStateVariables();
	if(currentState.State != "AwaitingCardRegistration") then
	(
		Error("Payment is not available for this contract");
	);

	contractParameters:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, System.Object);
	contractParameters["Message"]:= "Vaulter";

	cardRegistrationAmount:= select top 1 Value from currentState.VariableValues where Name = "CardRegistrationAmount";

	if(cardRegistrationAmount == null || cardRegistrationAmount <= 0) then 
	(
		Error("Authorization amount not available in contract.");
	);

	foreach var in currentState.VariableValues do
	(
		contractParameters[var.Name]:= var.Value;
	);
	contractParameters["RequestFromMobilePhone"]:= PIsFromMobile;
	contractParameters["AmountToPay"]:= cardRegistrationAmount;

	legalIdentityProperties:= select top 1 Properties from LegalIdentities where Id = Token.Owner;
	identityProperties:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, Waher.Persistence.CaseInsensitiveString);

	foreach prop in legalIdentityProperties do  
	(
		identityProperties[prop.Name]:= prop.Value;
	);

	if(!exists(Global.PayspotRequests)) then
	(
		Global.PayspotRequests:= Create(Waher.Runtime.Cache.Cache,System.String,System.String,System.Int32.MaxValue,System.TimeSpan.FromHours(0.5),System.TimeSpan.FromHours(0.5));	
	);

	Global.PayspotRequests[ContractId]:= PTabId;
	responseObject.Response:= POWRS.Payment.PaySpot.PayspotService.GenerateCardAuthorizationForm(contractParameters, identityProperties);

	Background(SendBuyerTimeZoneToToken(Request.RemoteEndPoint, PTimeZoneOffset, TokenId));
)
catch
(
 responseObject.Success:= false;
 responseObject.Message:= Exception.Message;
 Log.Error(Exception.Message, null);
);

responseObject;