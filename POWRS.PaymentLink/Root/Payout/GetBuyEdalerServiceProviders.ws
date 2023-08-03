({
    "Country": Required(Str(PCountry)),
	"Currency": Required(Str(PCurrency))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

P:=GetServiceProvidersForBuyingEDaler(PCountry,PCurrency);

{
  ServiceProviders:[P.Name, P.Id, P.IconUrl,P.BuyEDalerServiceProvider.Id, P.BuyEDalerTemplateContractId]T
}
