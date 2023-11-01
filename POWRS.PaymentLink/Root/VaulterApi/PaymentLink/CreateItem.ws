if !exists(Posted) then BadRequest("No payload.");

({
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency) like "[A-Z]{3}"),
    "description":Required(String(PDescription)),
    "deliveryDate":Required(String(PDeliveryDate)),
    "sellerBankAccount":Required(String(PClientBankAccount)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPersonalNum":Required(String(PBuyerPersonalNum)),
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Required(String(PCallBackUrl)),
    "password":Required(String(PPassword))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");
Response.SetHeader("Access-Control-Allow-Origin","*");

Jwt:= null;
try
(
    header:= null;
    Request.Header.TryGetHeaderField("Authorization", header);
    auth:= POST("https://" + Gateway.Domain + "/VaulterApi/PaymentLink/VerifyToken.ws", 
            {"includeInfo": true}, {"Accept": "application/json", "Authorization": header.Value});
   
    Jwt:= header.Value;   
    PUserName:= auth.userName;
)
catch
(
  Forbidden("Token not valid");
);

ParsedDeliveryDate:= null;
if(!System.DateTime.TryParse(PDeliveryDate, ParsedDeliveryDate)) then
(
  BadRequest("Delivery date must be in MM/dd/yyyy format");
);

if(ParsedDeliveryDate < Now) then 
(
 BadRequest("Delivery date must be in the future");
);

LegalId := select top 1 Id from IoTBroker.Legal.Identity.LegalIdentity I where I.Account = PUserName and State = 'Approved' order by Created desc;
if(System.String.IsNullOrEmpty(LegalId)) then
(
    BadRequest("User " + PUserName + " does not have approved legal identity so it is unable to sign contracts");
);

KeyId := GetSetting(PUserName + ".KeyId","");
KeyPassword:= GetSetting(PUserName + ".KeySecret","");

if(System.String.IsNullOrEmpty(KeyId) || System.String.IsNullOrEmpty(KeyPassword)) then 
(
    BadRequest("No signing keys or password available for user: " + PUserName);
);

normalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PBuyerCountryCode, PBuyerPersonalNum);
isValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PBuyerCountryCode ,normalizedPersonalNumber);

if(!isValid) then 
(
    BadRequest("Personal number: " + PBuyerPersonalNum + " is not valid for the country: " + PBuyerCountryCode);
);

Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
if Mode == TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox then
(
  TemplateId:= "2cca4fc9-ef22-ef53-901f-9e66b8194bd0@legal.lab.neuron.vaulter.rs"
)
else
(
  TemplateId:="2c9ad3b4-3004-2195-7817-9f1c469a0057@legal.neuron.vaulter.se";
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


GetBicResponse := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/VaulterApi/PaymentLink/GetBic.ws",
                 {
                    "bankAccount":  PClientBankAccount
                  },
		   {"Accept" : "application/json", "Authorization": Jwt});

PSellerServiceProviderId := GetBicResponse.serviceProviderId;
PSellerServiceProviderType := GetBicResponse.serviceProviderType;

 Identities:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = PUserName And State = 'Approved';

    AgentName := "";
    OrgName := "";
    foreach I in Identities do
    (
       AgentName := I.FIRST + " " + I.MIDDLE + " " + I.LAST;
       OrgName  := I.ORGNAME;
    );

    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;

try
Contract:=CreateContract(PUserName, TemplateId, "Public",
    {
        "RemoteId": PRemoteId,
	"Title": PTitle,
        "Description": PDescription,
        "Value": PPrice,
        "PaymentDeadline" : DateTime(Today.Year, Today.Month, Today.Day, 23, 59, 59, 00),
        "DeliveryDate" : DateTime(ParsedDeliveryDate.Year, ParsedDeliveryDate.Month, ParsedDeliveryDate.Day, 23, 59, 59, 00),
        "Currency": PCurrency,
        "Country": PBuyerCountryCode,
        "Expires": Today.AddDays(364),
        "SellerBankAccount" : PClientBankAccount,
        "SellerName" : SellerName,
        "SellerServiceProviderId" : PSellerServiceProviderId,
        "SellerServiceProviderType" : PSellerServiceProviderType,
        "BuyerFullName":PBuyerFirstName + " " + PBuyerLastName,
        "BuyerPersonalNum":PBuyerPersonalNum,
        "BuyerEmail":PBuyerEmail,
        "CallBackUrl" : PCallBackUrl
    })
catch
BadRequest(Exception.Message);

Nonce := Base64Encode(RandomBytes(32));

LocalName := "ed448";
Namespace := "urn:ieee:iot:e2e:1.0";

S1 := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + LegalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));
NeuronAddress:= "https://" + Waher.IoTGateway.Gateway.Domain;

POST(NeuronAddress + "/Agent/Legal/SignContract",
                             {
	                        "keyId": KeyId,
	                        "legalId": LegalId,
	                        "contractId": ContractId,
	                        "role": Role,
	                        "nonce": Nonce,
	                        "keySignature": KeySignature,
	                        "requestSignature": RequestSignature
                                },
			      {
			       "Accept" : "application/json",		       
                               "Authorization": Jwt
                              });

{
    "Link" : NeuronAddress + "/Payout/Payout.md?ID=" + Replace(ContractId,"@legal." + Waher.IoTGateway.Gateway.Domain,""),
    "EscrowFee": EscrowFee,
    "Currency": PCurrency
}
