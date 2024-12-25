
Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency)),
    "description":Required(String(PDescription)),
    "paymentDeadline": Required(String(PPaymentDeadline)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)),
    "buyerAddress": Required(Str(PBuyerAddress)) ,
    "buyerCity": Optional(Str(PBuyerCity)) ,
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
    "successUrl":Optional(String(PSuccessUrl)),
    "errorUrl":Optional(String(PErrorUrl)),
    "deliveryDate": Optional(Str(PDeliveryDate)),
	"totalNumberOfPayments": Optional(Num(PNumberOfPayments)),
    "ipsOnly": Optional(Bool(PIpsOnly))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    PayoutPage := "Payout.md";
    if(!exists(PIpsOnly)) then
    (
        PIpsOnly:= false;
    );

    IsEcommerce := false;
    ContractInfo := Global.CreateItem(SessionUser, PRemoteId, IsEcommerce,
                PTitle, PPrice, PCurrency, 
                PDescription, PPaymentDeadline, PDeliveryDate ?? null, PNumberOfPayments ?? null, 
			    PBuyerFirstName, PBuyerLastName, PBuyerEmail, PBuyerPhoneNumber ??? "",
			    PBuyerAddress , PBuyerCity ?? "", PBuyerCountryCode, 
			    PCallBackUrl ?? "", PWebPageUrl ?? "", PSuccessUrl ?? "", PErrorUrl ?? "",
			    logActor);
			
    PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");

    businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = SessionUser.username;
    if(businessData != null) then 
    (
     IpsOnly := (PIpsOnly or businessData.IPSOnly);
    );

    if IpsOnly then PayoutPage := "PayoutIPS.md";
    
    {
        "Link" : PaymentLinkAddress + "/" + ContractInfo.PayoutPage + "?ID=" + Global.EncodeContractId(ContractInfo.ContractId),	
        "TokenId" : ContractInfo.TokenId,
        "BuyerEmail": ContractInfo.BuyerEmail,
        "BuyerPhoneNumber": ContractInfo.BuyerPhoneNumber,
        "Currency": ContractInfo.Currency
    }

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
