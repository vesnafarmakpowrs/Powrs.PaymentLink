Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "orderNum":Required(String(PRemoteId) like "^(?!.*--)[a-zA-Z0-9-]{1,50}$"),
    "title":Required(String(PTitle) like "[a-zA-Z0-9.,;:!?()'\" -]{2,30}"),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency) like "[A-Z]{3}"),
    "description":Required(String(PDescription)  like "[a-zA-Z0-9.,;:!?()'\" -]{2,100}"),
    "deliveryDate":Required(String(PDeliveryDate) like "^(0[1-9]|1[0-2])\\/(0[1-9]|[12][0-9]|3[01])\\/\\d{4}$"),
    "sellerBankAccount":Required(String(PClientBankAccount)),
    "buyerFirstName":Required(String(PBuyerFirstName) like "[\\p{L}\\s]{2,20}"),
    "buyerLastName":Required(String(PBuyerLastName) like "[\\p{L}\\s]{2,20}"),
    "buyerEmail":Required(String(PBuyerEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "buyerPersonalNum":Optional(String(PBuyerPersonalNum)  like "\\d*-?\\d*"),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)  like "^\\+[0-9]{6,15}$"),
    "buyerCountryCode":Required(String(PBuyerCountryCode)  like "[A-Z]{2}"),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl)),
    "allowedServiceProviders": Optional(String(PAllowedServiceProviders))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(Request, Response);

PPassword:= select top 1 Password from BrokerAccounts where UserName = SessionUser.username;
if(System.String.IsNullOrWhiteSpace(PPassword)) then 
(
    BadRequest("No user with given username");
);

try 
(
 ParsedDeliveryDate:= System.DateTime.ParseExact(PDeliveryDate, "MM/dd/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
 if(ParsedDeliveryDate < Today) then 
 (
    Error("Delivery date must be in the future");
 );
)
catch
(
  BadRequest(Exception.Message);
);

KeyId := GetSetting(SessionUser.username + ".KeyId","");
KeyPassword:= GetSetting(SessionUser.username + ".KeySecret","");

if(System.String.IsNullOrEmpty(KeyId) || System.String.IsNullOrEmpty(KeyPassword)) then 
(
    BadRequest("No signing keys or password available for user: " + SessionUser.username);
);


if(exists(PBuyerPersonalNum) || PBuyerCountryCode.ToLower() == "se") then 
(
  try
  (
    normalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PBuyerCountryCode, PBuyerPersonalNum);
	isValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PBuyerCountryCode ,normalizedPersonalNumber);

	if(isValid != true) then 
	(
    	 Error("Personal number: " + PBuyerPersonalNum + " is not valid for the country: " + PBuyerCountryCode);
	);
  )
  catch
  (
    BadRequest(Exception.Message);
  );	
);

if(exists(PAllowedServiceProviders) and PAllowedServiceProviders != null) then 
(
    allowedServiceProviders:= Split(PAllowedServiceProviders, ";");
    if(allowedServiceProviders != null and allowedServiceProviders.Length > 0) then 
    (
       availableServiceProviders:= GetServiceProvidersForBuyingEdaler(PBuyerCountryCode, PCurrency).BuyEDalerServiceProvider.Id;
       foreach allowed in allowedServiceProviders do 
       (
          if(indexOf(availableServiceProviders, allowed) < 0) then 
          (
             BadRequest("Invalid service providers selected");
          );
       );
    );
)
else 
(
    PAllowedServiceProviders:= "";
);

TemplateId:= GetSetting("POWRS.PaymentLink.TemplateId","");

if(System.String.IsNullOrWhiteSpace(TemplateId)) then 
(
    BadRequest("Not configured correctly");
);

ContractParameters:= select top 1 Parameters from Contracts where ContractId = TemplateId;
if(ContractParameters == null) then 
(
 BadRequest("Parameters for the contract does not exists.");
);

EscrowFee:= 0;
foreach Parameter in ContractParameters do 
(
  Parameter.Name like "EscrowFee" ?   EscrowFee := Parameter.ObjectValue;
);

if(EscrowFee <= 0) then 
(
 BadRequest("Fee not properly configured");
);


GetBicResponse := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/VaulterApi/PaymentLink/Bank/GetBic.ws",
                 {
                    "bankAccount":  PClientBankAccount
                  },
		   {"Accept" : "application/json", "Authorization": "Bearer " + SessionUser.jwt});

PSellerServiceProviderId := GetBicResponse.serviceProviderId;
PSellerServiceProviderType := GetBicResponse.serviceProviderType;

 Identities:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = SessionUser.username And State = 'Approved';

    AgentName := "";
    OrgName := "";
    foreach I in Identities do
    (
       AgentName := I.FIRST + " " + I.MIDDLE + " " + I.LAST;
       OrgName  := I.ORGNAME;
    );

    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;

try
(
BuyerPersonalNum:= PBuyerPersonalNum ?? " ";
BuyerPhoneNumber:= PBuyerPhoneNumber ?? " ";
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
        "SellerBankAccount" : PClientBankAccount,
        "SellerName" : SellerName,
        "SellerServiceProviderId" : PSellerServiceProviderId,
        "SellerServiceProviderType" : PSellerServiceProviderType,
        "BuyerFullName": PBuyerFirstName + " " + PBuyerLastName,
        "BuyerPersonalNum": BuyerPersonalNum,
        "BuyerPhoneNumber": BuyerPhoneNumber,
        "BuyerEmail":PBuyerEmail,
        "CallBackUrl" : CallBackUrl,
        "WebPageUrl" : WebPageUrl,
        "AllowedServiceProviders": PAllowedServiceProviders
    })
)
catch
(
  BadRequest(Exception.Message);
  Log.Error(Exception, null);
);
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

{
    "Link" : NeuronAddress + "/Payout/Payout.md?ID=" + Replace(ContractId,"@legal." + Waher.IoTGateway.Gateway.Domain,""),
    "EscrowFee": EscrowFee,
    "Currency": PCurrency
}
