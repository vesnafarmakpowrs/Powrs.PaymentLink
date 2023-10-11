({
    "ContractId": Required(Str(PContractId)),
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

 Parameters:= p:= select top 1 Parameters from IoTBroker.Legal.Contracts.Contract ContractId= PContractId;
 if (Parameters == null) then
	Error("Parameters are missing");

Currency:= "";
CountryCode:= "";
foreach param in Parameters do
(
 if(param.Name == "Currency") then 
 (
   Currency:= param.ObjectValue;
 );
 if(param.Name == "Country") then 
 (
   CountryCode:= param.ObjectValue;
 );
);

if(System.String.IsNullOrWhiteSpace(Currency) || System.String.IsNullOrWhiteSpace(CountryCode)) then 
(
 Error("BadRequest");
);

Providers:=GetServiceProvidersForBuyingEDaler(CountryCode,Currency);
Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
QRcode := true;
counter :=0;
Name := "";
ProviderList := [
                   foreach P in Providers do 
                    ( 
                       Id:=  P.Id.Replace(Mode + '.','');
                       Id == 'HANDSESS' || Id == 'NDEASESS' || Id == 'ELLFSESS' || Id == 'DABASESX'? QRcode := false : QRcode := true;
                       Id == 'ESSESESS' ? Name := "SEB" : Name := P.Name;
                       Id == 'NDEASESS' ? Name := "Nordea";
                       Id == 'DABASESX' ? Name := "Danske Bank";
		               Id == 'ELLFSESS' ? Name := "LF Bank";

                      if Id != 'DNBASESX' then
                       {
                         "Name": Name, 
		                 "Id": P.Id, 
		                 "IconUrl": "https://" + P.Id.Replace("Production.",Waher.IoTGateway.Gateway.Domain + "/Payout/Bank/") + ".png",
		                 "BuyEDalerServiceProvider.Id": P.BuyEDalerServiceProvider.Id, 
		                 "BuyEDalerTemplateContractId": P.BuyEDalerTemplateContractId, 
		                 "QRCode" :QRcode
                       }
		   )
                ];

{
  ServiceProviders:ProviderList
}
