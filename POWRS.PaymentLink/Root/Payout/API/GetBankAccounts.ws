({
    "tabId": Required(Str(PTabID)),
	"sessionId": Required(Str(PSessionId)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
    "bicFi": Required(Str(PBicFi)),
    "bankName": Required(Str(PBankName))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionToken:= ValidatePayoutJWT();
PContractId:= SessionToken.Claims.contractId;

contractParameters:= select top 1 Parameters from IoTBroker.Legal.Contracts.Contract where ContractId = PContractId;
if(contractParameters == null) then
(
   BadRequest("Parameters for given contract do not exists");
);

personalNumber:= "";

index:= PBicFi.LastIndexOf('.');
if(index > -1) then 
(
 PBicFi:= PBicFi.Substring(index + 1);
);

OPServiceProvider:=Create(TAG.Payments.OpenPaymentsPlatform.OpenPaymentsPlatformServiceProvider);

ClientID := GetSetting("TAG.Payments.OpenPaymentsPlatform.ClientID","");
ClientSecret := GetSetting("TAG.Payments.OpenPaymentsPlatform.ClientSecret","");
Sniffer := Create(Waher.Networking.Sniffers.ConsoleOutSniffer, Waher.Networking.Sniffers.BinaryPresentationMethod.Base64 , Waher.Networking.Sniffers.LineEnding.NewLine);

Ip := Request.RemoteEndPoint.Substring(0,Request.RemoteEndPoint.IndexOf(":")); 

Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
if Mode == TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox then
(
 Client := TAG.Networking.OpenPaymentsPlatform.OpenPaymentsPlatformClient.CreateSandbox(ClientID, ClientSecret, ServicePurpose.Private, [Sniffer]);
 Ip := "192.168.0.1";
)
else
(
 foreach p in contractParameters DO 
 (
	if (p.Name == "BuyerPersonalNum") then 
	(
	   personalNumber:= p.ObjectValue;
	);
 );
 if(System.String.IsNullOrEmpty(personalNumber)) then
 (
	BadRequest("Personal number is not valid");
 );
 Certificate:= Create(System.Security.Cryptography.X509Certificates.X509Certificate2, System.Convert.FromBase64String(GetSetting("TAG.Payments.OpenPaymentsPlatform.Certificate","")), GetSetting("TAG.Payments.OpenPaymentsPlatform.CertificatePassword",""));
 Client := TAG.Networking.OpenPaymentsPlatform.OpenPaymentsPlatformClient.CreateProduction(ClientID, ClientSecret, Certificate, ServicePurpose.Private, [Sniffer])
);

AspService := Create(TAG.Networking.OpenPaymentsPlatform.AspServiceProvider, Client, PBicFi, PBankName, "");

OPService:=Create(TAG.Payments.OpenPaymentsPlatform.OpenPaymentsPlatformService, "SWEDEN", AspService , Mode, OPServiceProvider);

IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
IdentityProperties.Add("PNR", personalNumber);
IdentityProperties.Add("JID", "OPPUser@" + Gateway.Domain);

SuccessUrl:= "";
FailureUrl := "";
CancelUrl := "";

results := OPService.GetPaymentOptionsForBuyingEDaler(IdentityProperties, SuccessUrl, FailureUrl, CancelUrl, PTabID, PRequestFromMobilePhone,Ip);

{
	Results: results,
       "PBicFi" : PBicFi
}

