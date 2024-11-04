
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
    "errorUrl":Optional(String(PErrorUrl))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    PayoutPage := "Payout.md";
    IpsOnly := false;
    IsEcommerce := false;
    ContractInfo := Global.CreateItem(SessionUser, PRemoteId, IsEcommerce,
                PTitle, PPrice, PCurrency, 
                PDescription, PPaymentDeadline, 
			    PBuyerFirstName, PBuyerLastName, PBuyerEmail, PBuyerPhoneNumber ??? "",
			    PBuyerAddress , PBuyerCity ?? "", PBuyerCountryCode, 
			    PCallBackUrl ?? "", PWebPageUrl ?? "", PSuccessUrl ?? "", PErrorUrl ?? "",
			    logActor);

        contractParameters:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, System.Object);
        legalIdentityProperties:= select top 1 Properties from LegalIdentities where Id = SessionUser.legalId;
        identityProperties:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, Waher.Persistence.CaseInsensitiveString);

        foreach prop in legalIdentityProperties do  
	    (
	       identityProperties[prop.Name]:= prop.Value;
	    );

        variables:= select top 1 VariableValues from StateMachineCurrentStates where StateMachineId = ContractInfo.TokenId;
        contractParameters["Message"]:= "Vaulter";
        foreach var in  variables do
	    (
	        contractParameters[var.Name]:= var.Value;
	    );

    MerchantOrderId:= POWRS.Payment.PaySpot.PayspotService.GenerateOrder(contractParameters, identityProperties);
			
    PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");

    businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = SessionUser.username;
    if(businessData != null) then 
    (
     IpsOnly := businessData.IPSOnly;
    );

    if IpsOnly then PayoutPage := "PayoutIPS.md";
    
    {
        "Link" : PaymentLinkAddress + "/" + PayoutPage + "?ID=" + Global.EncodeContractId(ContractInfo.ContractId),	
        "TokenId" : ContractInfo.TokenId,
        "OrderId": MerchantOrderId,
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
