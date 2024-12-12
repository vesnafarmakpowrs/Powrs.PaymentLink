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

	ContractId:= SessionToken.Claims.contractId;
	TokenId:= SessionToken.Claims.tokenId;

	tokenVariablesResponse:= Global.GetTokenVariables(TokenId, "AwaitingCardRegistration", PIsFromMobile);
	identityProperties:= Global.GetIdentityProperties(tokenVariablesResponse.Owner);

	contractParameters:= tokenVariablesResponse.Variables;
	cardRegistrationAmount:= contractParameters["CardRegistrationAmount"] ?? 0;

	if(cardRegistrationAmount == null || cardRegistrationAmount <= 0) then 
	(
		Error("Card registration amount not available in contract.");
	);

	contractParameters["AmountToPay"]:= cardRegistrationAmount;

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