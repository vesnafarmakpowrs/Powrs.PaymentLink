({
    "Country": Required(Str(PCountry)),
    "Currency": Required(Str(PCurrency))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Providers:=GetServiceProvidersForBuyingEDaler(PCountry,PCurrency);
QRcode := true;
counter :=0;
Name := "";
ProviderList := [
                   foreach P in Providers do 
                    (
                       P.Id == 'Production.HANDSESS' || P.Id == 'Production.NDEASESS' || P.Id == 'Production.ELLFSESS' || P.Id == 'Production.DABASESX'? QRcode := false : QRcode := true;
                       P.Id == "Production.ESSESESS" ? Name := "SEB" : Name := P.Name;
                       P.Id == "Production.NDEASESS" ? Name := "Nordea";
                       P.Id == "Production.DABASESX" ? Name := "Danske Bank";
		               P.Id == "Production.ELLFSESS" ? Name := "LF Bank";

                      if P.Id != 'Production.DNBASESX' then
                       {
                         "Name": Name, 
		                 "Id": P.Id, 
		                 "IconUrl": P.IconUrl,
		                 "BuyEDalerServiceProvider.Id": P.BuyEDalerServiceProvider.Id, 
		                 "BuyEDalerTemplateContractId": P.BuyEDalerTemplateContractId, 
		                 "QRCode" :QRcode
                       }
		           )
                 ];

{
  ServiceProviders:ProviderList
}
