({
    "SelectedServiceProviders": Optional(Str(PSelectedProvidersString))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionToken:=  Global.ValidatePayoutJWT();
PContractId:= SessionToken.Claims.contractId;

 Parameters:= select top 1 Parameters from IoTBroker.Legal.Contracts.Contract where ContractId= PContractId;
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
allowedServiceProviders:= [];
if(exists(PSelectedProvidersString) and !System.String.IsNullOrWhiteSpace(PSelectedProvidersString)) then 
(
     allowedServiceProviders:= Split(PSelectedProvidersString, ";");
);

Providers:=GetServiceProvidersForBuyingEDaler(CountryCode,Currency);
Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
QRcode := true;
Name := "";
ProviderList := Create(System.Collections.Generic.List, System.Object);
PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");

foreach P in Providers do 
 ( 
 	if((allowedServiceProviders.Length > 0 and indexOf(allowedServiceProviders, P.BuyEDalerServiceProvider.Id) != -1) OR allowedServiceProviders.Length <= 0) then 
 	(
   		     Id:=  P.Id.Replace(Mode + '.','');
    		 Id == 'HANDSESS' || Id == 'NDEASESS' || Id == 'ELLFSESS' || Id == 'DABASESX'? QRcode := false : QRcode := true;
    		 Id == 'ESSESESS' ? Name := "SEB" : Name := P.Name;
    		 Id == 'NDEASESS' ? Name := "Nordea";
   		     Id == 'DABASESX' ? Name := "Danske Bank";
             Id == 'ELLFSESS' ? Name := "LF Bank";

   		if Id != 'DNBASESX' then 
        (
          ProviderList.Add({
      	        "Name": Name, 
	            "Id": P.Id, 
	            "IconUrl": "https://" + P.Id.Replace("Production.","/" + PaylinkDomain + "/Bank/") + ".png",
	            "BuyEDalerServiceProviderId": P.BuyEDalerServiceProvider.Id, 
	            "BuyEDalerTemplateContractId": P.BuyEDalerTemplateContractId, 
	            "QRCode" :QRcode
    		});
        );    		
  );
);

{
  ServiceProviders: ProviderList
}
