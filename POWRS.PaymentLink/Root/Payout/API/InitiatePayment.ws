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
		IpsOnly:=  SessionToken.Claims.ipsOnly;
	);

	ContractId:= SessionToken.Claims.contractId;
	TokenId:= SessionToken.Claims.tokenId;
	
	tokenVariablesResponse:=  Global.GetTokenVariables(TokenId, "AwaitingForPayment", PIsFromMobile);
	identityProperties:= Global.GetIdentityProperties(tokenVariablesResponse.Owner);

	if(!exists(Global.PayspotRequests)) then
	(
		Global.PayspotRequests:= Create(Waher.Runtime.Cache.Cache,System.String,System.String,System.Int32.MaxValue,System.TimeSpan.FromHours(0.5),System.TimeSpan.FromHours(0.5));	
	);

	Global.PayspotRequests[ContractId]:= PTabId;

	if(IpsOnly) then
	(
		GeneratedIPSForm:= POWRS.Payment.PaySpot.PayspotService.GenerateIPSForm(tokenVariablesResponse.Variables, identityProperties);
		responseObject.Response:= GeneratedIPSForm.ToDictionary();
	)
	else
	(
		responseObject.Response:= POWRS.Payment.PaySpot.PayspotService.GeneratePayspotLink(tokenVariablesResponse.Variables, identityProperties);
	);

	Background(SendBuyerTimeZoneToToken(Request.RemoteEndPoint, PTimeZoneOffset, TokenId));
)
catch
(
 responseObject.Success:= false;
 responseObject.Message:= Exception.Message;
 Log.Error(Exception.Message, null);
);

responseObject;