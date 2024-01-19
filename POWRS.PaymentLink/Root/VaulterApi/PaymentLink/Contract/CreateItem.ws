Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "orderNum":Required(String(PRemoteId) like "^(?!.*--)[a-zA-Z0-9-]{1,50}$"),
    "title":Required(String(PTitle) like "[a-zA-Z0-9.,;:!?()'\" -]{2,30}"),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency) like "[A-Z]{3}"),
    "description":Required(String(PDescription)  like "[a-zA-Z0-9.,;:!?()'\" -]{2,100}"),
    "deliveryDate":Required(String(PDeliveryDate) like "^(0[1-9]|1[0-2])\\/(0[1-9]|[12][0-9]|3[01])\\/\\d{4}$"),
    "buyerFirstName":Required(String(PBuyerFirstName) like "[\\p{L}\\s]{2,20}"),
    "buyerLastName":Required(String(PBuyerLastName) like "[\\p{L}\\s]{2,20}"),
    "buyerEmail":Required(String(PBuyerEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)  like "^[+]?[0-9]{6,15}$"),
    "buyerAddress": Required(Str(PBuyerAddress) like "^(?!\\s{2,})(?!.*[^a-zA-Z0-9\\s]).{1,50}$") ,
    "buyerCountryCode":Required(UpperCase(String(PBuyerCountryCode))  like "[A-Z]{2}"),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
    "supportedPaymentMethods": Optional(String(PSupportedPaymentMethods))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

try
(

PPassword:= select top 1 Password from BrokerAccounts where UserName = SessionUser.username;
if(System.String.IsNullOrWhiteSpace(PPassword)) then 
(
    Error("No user with given username");
);

ParsedDeliveryDate:= System.DateTime.ParseExact(PDeliveryDate, "MM/dd/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
if(ParsedDeliveryDate < Today) then 
(
    Error("Delivery date must be in the future");
);

KeyId := GetSetting(SessionUser.username + ".KeyId","");
KeyPassword:= GetSetting(SessionUser.username + ".KeySecret","");

if(System.String.IsNullOrEmpty(KeyId) || System.String.IsNullOrEmpty(KeyPassword)) then 
(
    Error("No signing keys or password available for user: " + SessionUser.username);
);

if(exists(PSupportedPaymentMethods) and PSupportedPaymentMethods != null) then 
(
    supportedPaymentMethods:= Split(PSupportedPaymentMethods, ";");
    if(supportedPaymentMethods != null and supportedPaymentMethods.Length > 0) then 
    (
       supportedPaymentMethods:= GetServiceProvidersForBuyingEdaler(PBuyerCountryCode, PCurrency).BuyEDalerServiceProvider.Id;
       foreach allowed in supportedPaymentMethods do 
       (
          if(indexOf(supportedPaymentMethods, allowed) < 0) then 
          (
             Error("Invalid service providers selected");
          );
       );
    );
)
else 
(
    PSupportedPaymentMethods:= "";
);

TemplateId:= GetSetting("POWRS.PaymentLink.TemplateId","");

if(System.String.IsNullOrWhiteSpace(TemplateId)) then 
(
    Error("Not configured correctly");
);

ContractParameters:= select top 1 Parameters from Contracts where ContractId = TemplateId;
if(ContractParameters == null) then 
(
 Error("Parameters for the contract does not exists.");
);

EscrowFee:= 0;
foreach Parameter in ContractParameters do 
(
  Parameter.Name like "EscrowFee" ?   EscrowFee := Parameter.ObjectValue;
);

if(EscrowFee <= 0) then 
(
 Error("Fee not properly configured");
);

  Identity := select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = SessionUser.username And State = 'Approved';

    AgentName := Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST;
    OrgName  := Identity.ORGNAME;
   
    if (System.String.IsNullOrEmpty(Identity.ORGBANKNUM)) then
       Error("Legal identity for this " + SessionUser.username + " mising bank account number");
    
    SellerBankAccount := Identity.ORGBANKNUM;
    SellerCountry := Identity.ORGCOUNTRY;
    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;

    PSellerServiceProviderId := "";
    PSellerServiceProviderType := "";
    
    if (SellerCountry == 'SE') then
    (
           GetBicResponse := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/VaulterApi/PaymentLink/Bank/GetBic.ws",
                   {
                    "bankAccount":  SellerBankAccount
                   },
		   {"Accept" : "application/json", "Authorization": "Bearer " + SessionUser.jwt});

          PSellerServiceProviderId := GetBicResponse.serviceProviderId;
          PSellerServiceProviderType := GetBicResponse.serviceProviderType;
     );

BuyerPhoneNumber:= PBuyerPhoneNumber ?? "";
CallBackUrl:=  PCallBackUrl ?? "";
WebPageUrl:=  PWebPageUrl ?? "";

Contract:=CreateContract(SessionUser.username, TemplateId, "Public",
    {
        "RemoteId": PRemoteId,
	    "Title": PTitle,
        "Description": PDescription,
        "Value": PPrice,
        "PaymentDeadline" : DateTime(Today.Year, Today.Month, Today.Day, 23, 59, 59, 00).ToUniversalTime(),
        "DeliveryDate" : DateTime(ParsedDeliveryDate.Year, ParsedDeliveryDate.Month, ParsedDeliveryDate.Day, 23, 59, 59, 00).ToUniversalTime(),
        "Currency": PCurrency,
        "Country": PBuyerCountryCode,
        "Expires": TodayUtc.AddDays(364),
        "SellerBankAccount" : SellerBankAccount,
        "SellerName" : SellerName,
        "SellerServiceProviderId" : PSellerServiceProviderId,
        "SellerServiceProviderType" : PSellerServiceProviderType,
        "BuyerFullName": PBuyerFirstName + " " + PBuyerLastName,
        "BuyerPhoneNumber": BuyerPhoneNumber,
        "BuyerEmail":PBuyerEmail,
        "CallBackUrl" : CallBackUrl,
        "WebPageUrl" : WebPageUrl,
        "SupportedPaymentMethods": PSupportedPaymentMethods,
        "BuyerAddress": PBuyerAddress
    });

Nonce := Base64Encode(RandomBytes(32));

LocalName := "ed448";
Namespace := "urn:ieee:iot:e2e:1.0";

S1 := SessionUser.username + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + SessionUser.legalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));
NeuronAddress:= "https://" + Waher.IoTGateway.Gateway.Domain;
PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");
POST(NeuronAddress + "/Agent/Legal/SignContract",
                             {
	                        "keyId": KeyId,
	                        "legalId": SessionUser.legalId,
	                        "contractId": ContractId,
	                        "role": Role,
	                        "nonce": Nonce,
	                        "keySignature": KeySignature,
	                        "requestSignature": RequestSignature
                                },
			      {
			       "Accept" : "application/json",
			       "Authorization": "Bearer " + SessionUser.jwt
                              });

StateMachineInitialized:= false;
Counter:= 0;
while StateMachineInitialized == false and Counter < 10 do 
(
 Token:= select top 1 * from IoTBroker.NeuroFeatures.Token where OwnershipContract= Contract.ContractId;
 if(Token != null) then 
 (
    StateMachineInitialized:= Token.HasStateMachine;    
 );
 Counter += 1;
 Sleep(1000);
);

{
    "Link" : PaymentLinkAddress + "/Payout.md?ID=" + Global.EncodeContractId(ContractId),
    "EscrowFee": EscrowFee,
    "Currency": PCurrency
}

)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
