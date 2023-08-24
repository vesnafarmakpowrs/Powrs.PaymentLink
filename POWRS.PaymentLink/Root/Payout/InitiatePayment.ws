({
	"buyEdalerTemplateId":Required(Str(PBuyEdalerTemplateId)),
    "tabId": Required(Str(PTabID)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"contractId": Required(Str(PContractId)),
	"bankAccount": Required(Str(PBuyerBankAccount)),
	"bic" :Required(Str(PBic))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId = PContractId;
Token:= select top 1 * from NeuroFeatureTokens where OwnershipContract = PContractId;

if (Contract == null || Token == null) then 
(
	NotFound("Contract or token not found.")
);
	
P:=GetServiceProvidersForSellingEDaler('SE','SEK');
ServiceProviderId := "";
ServiceProviderType := "";
foreach asp in P do
  if Contains(asp.Id,PBic) then 
    (
	  ServiceProviderId := asp.Id;
	  ServiceProviderType := asp.SellEDalerServiceProvider.Id + ".OpenPaymentsPlatformServiceProvider";
    );

AmountToPay:= 0;
Currency:= "";
CallBackUrl:= "";
Value := 0;
EscrowFee := 0;

foreach Parameter in (Contract.Parameters ?? []) do 
	  (
         Parameter.Name like "AmountToPay" ?  AmountToPay := System.String.IsNullOrEmpty(Parameter.MarkdownValue)? 0 :Parameter.MarkdownValue ;
         Parameter.Name like "Value" ?  Value := System.String.IsNullOrEmpty(Parameter.MarkdownValue)? 0 :Parameter.MarkdownValue ;
         Parameter.Name like "EscrowFee" ?  EscrowFee := System.String.IsNullOrEmpty(Parameter.MarkdownValue)? 0 :Parameter.MarkdownValue ;
		 Parameter.Name like "Currency" ?  Currency := Parameter.MarkdownValue;
		 Parameter.Name like "CallBackUrl" ?  CallBackUrl := Parameter.MarkdownValue;
      );
AmountToPay := EscrowFee + Value;

if (Int(AmountToPay) <= 0 || System.String.IsNullOrEmpty(Currency)) then 
(
  BadRequest("Amount or currency not existing in the contract");
);

OPService :=Create(POWRS.Payout.PayoutService);
InitiatePaymentRequest := Create(POWRS.PaymentLink.Model.InitiatePaymentRequest);

InitiatePaymentRequest.Amount := AmountToPay;
InitiatePaymentRequest.CallBackUrl := CallBackUrl;
InitiatePaymentRequest.TokenId := Token.TokenId;
InitiatePaymentRequest.OwnerJid := Token.OwnerJid;
InitiatePaymentRequest.Currency := Currency;
InitiatePaymentRequest.BuyEdalerTemplateId := PBuyEdalerTemplateId;
InitiatePaymentRequest.ContractId := PContractId;
InitiatePaymentRequest.BankAccount := PBuyerBankAccount;
InitiatePaymentRequest.ServiceProviderId := ServiceProviderId;
InitiatePaymentRequest.ServiceProviderType := ServiceProviderType;
InitiatePaymentRequest.TabId := PTabID;
InitiatePaymentRequest.RequestFromMobilePhone := false;
InitiatePaymentRequest.RemoteEndpoint := Request.RemoteEndPoint;

results := OPService.InitiatePayment(InitiatePaymentRequest);

{
	Results: results
}