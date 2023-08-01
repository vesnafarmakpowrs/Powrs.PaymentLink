({
    	"tabId": Required(Str(PTabID)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"contractId": Required(Str(PContractId)),
	"bankAccount": Required(Str(PBuyerBankAccount))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

OPService:=Create(POWRS.Payout.PayoutService);
PRequestFromMobilePhone:= False;
results := OPService.BuyEDaler(PContractId, PBuyerBankAccount, PTabID, PRequestFromMobilePhone, Request.RemoteEndPoint);

{
	Results: results
}