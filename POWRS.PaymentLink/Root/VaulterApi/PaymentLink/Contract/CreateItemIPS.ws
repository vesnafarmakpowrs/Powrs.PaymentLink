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
	"isMobile":Required(Bool(PIsMobile)),
	"isCompany":Optional(Bool(PIsCompany))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(

    ContractInfo := Global.CreateItem(SessionUser, PRemoteId, 
                PTitle, PPrice, PCurrency, 
                PDescription, PPaymentDeadline, 
			    PBuyerFirstName, PBuyerLastName, PBuyerEmail, PBuyerPhoneNumber,
			    PBuyerAddress , PBuyerCity ?? "", PBuyerCountryCode, 
			    PBuyerPhoneNumber ?? "" , 
			    PCallBackUrl ?? "", 
			    logActor);
   
	PayoutPage := "EC/IPSQR.md";  
	Parameter := "";
	if (PIsMobile) then 
	(
	   if (exists(PIsCompany))  then
	   (
		  PayoutPage := "EC/IPSBank.md";
		  if (PIsCompany) then
		  (
			Parameter := "&TYPE=LE";
		  )
		  else 
		  (
			Parameter := "&TYPE=IE";
		  )
	   )
	   else
	   (
		  PayoutPage := "EC/IPSType.md";
	   )
	); 
	
	PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");
	{
		"Link" : PaymentLinkAddress + "/" + PayoutPage + "?ID=" + Global.EncodeContractId(ContractInfo.ContractId)+ Parameter,	
		"TokenId" : ContractInfo.TokenId,
		"EscrowFee": ContractInfo.EscrowFee,
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
