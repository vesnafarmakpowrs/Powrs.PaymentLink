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

State:= select top 1 State from StateMachineCurrentStates where StateMachineId = Token.MachineId;
if(State.Equals("AwaitingForPayment")) then 
(
 BadRequest("Payment is no longer possible for this item.");
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
PersonalNumber:= "";

foreach Parameter in (Contract.Parameters ?? []) do 
	  (
         Parameter.Name like "Value" ?  Value := Parameter.ObjectValue ?? 0 ;
         Parameter.Name like "EscrowFee" ?  EscrowFee := Parameter.ObjectValue ?? 0;
		 Parameter.Name like "Currency" ?  Currency := Parameter.MarkdownValue;
		 Parameter.Name like "CallBackUrl" ?  CallBackUrl := Parameter.MarkdownValue;
		 Parameter.Name like "BuyerPersonalNum" ?  PersonalNumber := Parameter.MarkdownValue;
      );
AmountToPay :=  Value + EscrowFee;

if (AmountToPay < 1 || System.String.IsNullOrEmpty(Currency)) then 
(
  BadRequest("Amount or currency not existing in the contract");
);

if(System.String.IsNullOrEmpty(PersonalNumber)) then 
(
	 BadRequest("Personal number is not found in the contract");
);

OPService :=Create(POWRS.Payout.PayoutService);
InitiatePaymentRequest := Create(POWRS.PaymentLink.Model.InitiatePaymentRequest);

InitiatePaymentRequest.Amount := AmountToPay;
InitiatePaymentRequest.CallBackUrl := CallBackUrl;
InitiatePaymentRequest.TokenId := Token.TokenId;
InitiatePaymentRequest.OwnerJid := Token.OwnerJid;
InitiatePaymentRequest.Currency := Currency;
InitiatePaymentRequest.PersonalNumber := PersonalNumber;
InitiatePaymentRequest.BuyEdalerTemplateId := PBuyEdalerTemplateId;
InitiatePaymentRequest.ContractId := PContractId;
InitiatePaymentRequest.BankAccount := PBuyerBankAccount;
InitiatePaymentRequest.ServiceProviderId := ServiceProviderId;
InitiatePaymentRequest.ServiceProviderType := ServiceProviderType;
InitiatePaymentRequest.TabId := PTabID;
InitiatePaymentRequest.RequestFromMobilePhone := PRequestFromMobilePhone;
InitiatePaymentRequest.RemoteEndpoint := Request.RemoteEndPoint;

results := OPService.InitiatePayment(InitiatePaymentRequest);
{
	Results: results
}