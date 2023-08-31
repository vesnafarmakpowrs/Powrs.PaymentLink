
if !exists(Posted) then BadRequest("No payload.");

({
    "userName": Required(String(PUserName)),
    "password": Required(String(PPassword)),
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Integer(PPrice)),
    "currency":Required(String(PCurrency) like "[A-Z]{3}"),
    "description":Required(String(PDescription)),
    "paymentDeadline":Required(DateTime(PPaymentDeadline)),
    "deliveryDate":Required(DateTime(PDeliveryDate)),
    "sellerBankAccount":Required(String(PClientBankAccount)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPersonalNum":Required(String(PBuyerPersonalNum)),
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallBackUrl))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

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

Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));
NeuronAddress:= "https://" + Waher.IoTGateway.Gateway.Domain;

R := POST(NeuronAddress + "/Agent/Account/Login",

                 {
                  "userName": PUserName,
                  "nonce": Nonce,
	              "signature": Signature,
	              "seconds": 10
                  },
		{"Accept" : "application/json"});

Token := "Bearer " + R.jwt;

Mode:=GetSetting("TAG.Payments.OpenPaymentsPlatform.Mode",TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox);
if Mode == TAG.Payments.OpenPaymentsPlatform.OperationMode.Sandbox then
(
  TemplateId:= "2c830a59-78d9-2a49-f419-5573a1088c1b@legal.lab.neuron.vaulter.rs";
)
else
(
  TemplateId:="2c830abd-c0fb-49b2-741b-37334d79a272@legal.neuron.vaulter.se";
);

Contract:=CreateContract(PUserName,TemplateId, "Public",
    {
        "RemoteId": PRemoteId,
	    "Title": PTitle,
        "Description": PDescription,
        "Value": PPrice,
        "PaymentDeadline" : Today.AddDays(364),
        "DeliveryDate" : Today.AddDays(364),
        "Currency": PCurrency,       
        "Expires": Today.AddDays(364),
        "SellerBankAccount" : PClientBankAccount,
        "BuyerFullName":PBuyerFirstName + " " + PBuyerLastName,
        "BuyerPersonalNum":PBuyerPersonalNum,
        "BuyerEmail":PBuyerEmail,
        "CallBackUrl" : PCallBackUrl
    });

Nonce := Base64Encode(RandomBytes(32));

LocalName := "ed448";
Namespace := "urn:ieee:iot:e2e:1.0";

S1 := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + LegalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

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
                           "Authorization": Token
                              });


{
    "Link" : NeuronAddress + "/Payout/Payout.md?ID=" + Replace(ContractId,"@legal." + Waher.IoTGateway.Gateway.Domain,"")
}
