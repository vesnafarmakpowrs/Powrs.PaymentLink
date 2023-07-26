({
    "tabId": Required(Str(PTabID)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"bicFi": Required(Str(PBicFi)),
	"bankName": Required(Str(PBankName)),
	"contractId": Required(Str(PContractId)),
	"bankAccount": Required(Str(PBuyerBankAccount)),
	"personalNumber": Required(Str(PPersonalNumber))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

index:= PBicFi.LastIndexOf('.');
if(index > -1) then 
(
 PBicFi:= PBicFi.Substring(index + 1);
);

RequestEndPoint:= Request.RemoteEndPoint;
OPServiceProvider:=Create(POWRS.Payout.PayoutServiceProvider);

ClientID := GetSetting("TAG.Payments.OpenPaymentsPlatform.ClientID","");
ClientSecret := GetSetting("TAG.Payments.OpenPaymentsPlatform.ClientSecret","");

Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
Sniffer := Create(Waher.Networking.Sniffers.ConsoleOutSniffer, Waher.Networking.Sniffers.BinaryPresentationMethod.Base64 , Waher.Networking.Sniffers.LineEnding.NewLine);

if Mode == TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox then
(
 RequestEndPoint:= "192.168.0.1";
 PPersonalNumber := "";
 Client := TAG.Networking.OpenPaymentsPlatform.OpenPaymentsPlatformClient.CreateSandbox(ClientID, ClientSecret, ServicePurpose.Private, [Sniffer])
)
else
(
 Client := TAG.Networking.OpenPaymentsPlatform.OpenPaymentsPlatformClient.CreateProduction(ClientID, ClientSecret, Certificate, ServicePurpose.Private, [Sniffer])
);

AspService := Create(TAG.Networking.OpenPaymentsPlatform.AspServiceProvider, Client, PBicFi, PBankName, "");
OPService:=Create(POWRS.Payout.PayoutService, "SWEDEN", AspService , Mode, OPServiceProvider);

RequestFromMobilePhone:= False;
results := OPService.BuyEDaler(PContractId, PBuyerBankAccount, PPersonalNumber, PTabID, RequestFromMobilePhone, RequestEndPoint);

{
	Results: results
}

