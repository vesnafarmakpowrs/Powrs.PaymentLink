({
    "tabId": Required(Str(PTabID)),
	"sessionId": Required(Str(PSessionId)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"bicFi": Required(Str(PBicFi)),
	"bankName": Required(Str(PBankName)),
	"countryCode": Required(Str(PCountryCode)),
	"contractId": Required(Str(PContractId)),
	"bankAccount": Required(Str(PAccount))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

personalNumber:= "";

index:= PBicFi.LastIndexOf('.');
if(index > -1) then 
(
 PBicFi:= PBicFi.Substring(index + 1);
);

contractParameters:= select top 1 Parameters from IoTBroker.Legal.Contracts.Contract where ContractId = PContractId;
if(contractParameters == null) then
(
   BadRequest("Parameters for given contract do not exists");
);

ContractAmount:= 0;
ContractCurrency:= "";
ContractAccount:= "";

foreach p in contractParameters DO 
(
	if (p.Name == "Value") then 
	(
	   ContractAmount:= Double(p.ObjectValue);
	);
	if(p.Name == "Currency") then 
	(
	  ContractCurrency:= p.ObjectValue;
	);
	if(p.Name == "BuyerPersonalNum") then
	(
	  personalNumber:= p.ObjectValue;
	);
);


account:= select top 1 Account from IoTBroker.Legal.Contracts.Contract where ContractId = PContractId

if(ContractAmount <= 0 || System.String.IsNullOrEmpty(ContractCurrency) || System.String.IsNullOrEmpty(account)) then 
(
	BadRequest("Amount, currency and account could not be empty");
);

contractAccount:= account + Gateway.Domain;

OPServiceProvider:=Create(POWRS.Payout.PayoutServiceProvider);

ClientID := GetSetting("TAG.Payments.OpenPaymentsPlatform.ClientID","");
ClientSecret := GetSetting("TAG.Payments.OpenPaymentsPlatform.ClientSecret","");

Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
Sniffer := Create(Waher.Networking.Sniffers.ConsoleOutSniffer, Waher.Networking.Sniffers.BinaryPresentationMethod.Base64 , Waher.Networking.Sniffers.LineEnding.NewLine);

if Mode == TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox then
(
 personalNumber:= "";
 Client := TAG.Networking.OpenPaymentsPlatform.OpenPaymentsPlatformClient.CreateSandbox(ClientID, ClientSecret, ServicePurpose.Private, [Sniffer])
)
else
(
 Client := TAG.Networking.OpenPaymentsPlatform.OpenPaymentsPlatformClient.CreateProduction(ClientID, ClientSecret, Certificate, ServicePurpose.Private, [Sniffer])
);

AspService := Create(TAG.Networking.OpenPaymentsPlatform.AspServiceProvider, Client, PBicFi, PBankName, "");
OPService:=Create(POWRS.Payout.PayoutService, "SWEDEN", AspService , Mode, OPServiceProvider);

IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
IdentityProperties.Add("PNR", personalNumber);
IdentityProperties.Add("JID", contractAccount);

ContractParameters := Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,System.Object);
ContractParameters.Add("Amount", ContractAmount);
ContractParameters.Add("Currency", ContractCurrency);
ContractParameters.Add("Account", PAccount);

SuccessUrl:= "";
FailureUrl := "";
CancelUrl := "";

results := OPService.BuyEDaler(ContractParameters,PContractId,IdentityProperties, SuccessUrl, FailureUrl, PTabID, False,"192.168.0.1");

{
	Results: results
}

