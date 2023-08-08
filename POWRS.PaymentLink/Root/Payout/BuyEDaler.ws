({
	"buyEdalerTemplateId":Required(Str(PBuyEdalerTemplateId)),
        "tabId": Required(Str(PTabID)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"contractId": Required(Str(PContractId)),
	"bankAccount": Required(Str(PBuyerBankAccount)),
	"bic" :Required(Str(PBic))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

P:=GetServiceProvidersForSellingEDaler('SE','SEK');
ServiceProviderId := "";
ServiceProviderType := "";
foreach asp in P do
  if Contains(asp.Id,PBic) then 
    (
	  ServiceProviderId := asp.Id;
	  ServiceProviderType := asp.SellEDalerServiceProvider.Id + ".OpenPaymentsPlatformServiceProvider";
    );


OPService:=Create(POWRS.Payout.PayoutService);
PRequestFromMobilePhone:= False;
results := OPService.BuyEDaler(PBuyEdalerTemplateId, PContractId, PBuyerBankAccount, ServiceProviderId, ServiceProviderType, PTabID, PRequestFromMobilePhone, Request.RemoteEndPoint);

{
	Results: results
}