SessionToken:=  Global.ValidatePayoutJWT();

({
    "isFromMobile":Required(Bool(PIsFromMobile)),
	"tabId": Required(Str(PTabId)),
	"ipsOnly": Required(Bool(PIpsOnly)),
	"bankId": Required(Int(PBankId)),
    "isCompany" : Required(Bool(PIsCompany)),
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
	
	token:= select top 1 * from IoTBroker.NeuroFeatures.Token t where t.TokenId = TokenId;
	if(token == null) then 
	(
		BadRequest("Token does not exists");
	);
	
	currentState:= token.GetCurrentStateVariables();
	if(currentState.State != "AwaitingForPayment" && currentState.State != "AwaitingforRefundPayment") then
	(
		Error("Payment is not available for this contract");
	);

	isRefundPayment := false;
	currentState.State == "AwaitingforRefundPayment" ? isRefundPayment := true;

	contractParameters:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, System.Object);
	contractParameters["Message"]:= "Vaulter";

	foreach var in currentState.VariableValues do 
	(
	 contractParameters[var.Name]:= var.Value;
	);

	contractParameters["RequestFromMobilePhone"]:= PIsFromMobile;

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
        
	if (PIpsOnly) then 
	(
	   if (exists(PBankId)) then (
	     GeneratedIPSData:= POWRS.Payment.PaySpot.PayspotService.GenerateIPSData(contractParameters, identityProperties, PBankId, 150, PIsCompany, isRefundPayment);
		 responseObject.Response:= GeneratedIPSData.ToDictionary();
	   );		
	)
	else
	(
		responseObject.Response:= POWRS.Payment.PaySpot.PayspotService.GeneratePayspotLink(contractParameters, identityProperties);
	);

	payspotPayment:= select top 1 * from PayspotPayments where TokenId = TokenId order by DateCreated desc;
	if(payspotPayment == null) then
	(
		InternalServerError();
	);

	SendIPSPaymentCompleted(payspotPayment):= 
    (
            try
            (

				Sleep(10000);
                
				jsonRequest:= {};
				jsonRequest.orderID:= payspotPayment.OrderId;
				jsonRequest.rnd:= "rnd_" + System.Guid.NewGuid();
				jsonRequest.result:= "00";
				jsonRequest.amount:= payspotPayment.Amount;
				jsonRequest.paySpotOrderID:= "payspotOrderId_" + System.Guid.NewGuid();
				jsonRequest.hash:= POWRS.Networking.PaySpot.Helper.ComputeSHA512Hash(jsonRequest.rnd + "|" + jsonRequest.paySpotOrderID + "|" + jsonRequest.orderID + "|" + POWRS.Payment.PaySpot.ServiceConfiguration.GetCurrent().WebhookSecretKey);

				url:= Gateway.GetUrl("/Payspot/PaymentInfo");
				Post(url, jsonRequest, {"Accept" : "application/json"});
            )
            catch
            (
                Log.Error(Exception.Message, null);
            );
   );

	Background(SendBuyerTimeZoneToToken(Request.RemoteEndPoint, PTimeZoneOffset, TokenId));
	Background(SendIPSPaymentCompleted(payspotPayment));
)
catch
(
 responseObject.Success:= false;
 responseObject.Message:= Exception.Message;
 Log.Error(Exception.Message, null);
);

responseObject;