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

normalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PBuyerCountryCode, PBuyerPersonalNum);
isValid = Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PBuyerCountryCode ,normalizedPersonalNumber);

if(!isValid) then 
(
    BadRequest("Personal number:" + PBuyerPersonalNum + " is not valid for the country: " + PBuyerCountryCode);
)

Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));
NeuronAddress:= "https://" + Waher.IoTGateway.Gateway.Domain;

R := POST(NeuronAddress + "/Agent/Account/Login",
                 {
                  "userName": PUserName,
                  "nonce": Nonce,
	              "signature": Signature,
	              "seconds": 60
                  },
		{"Accept" : "application/json"});

Token := "Bearer " + R.jwt;

TemplateId:="2c68d4ab-03bc-fba1-4019-d59180c12602@legal.lab.neuron.vaulter.rs";

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
        "CallBackUrl" : PCallBackUrl
    });

    
LegalIdentity :=select top 1 * from IoTBroker.Legal.Identity.LegalIdentity I where I.Account = PUserName and State = 'Approved' order by Created desc ;

LegalId := LegalIdentity.Id;
Nonce := Base64Encode(RandomBytes(32));

LocalName := "ed448";
Namespace := "urn:ieee:iot:e2e:1.0";
KeyId := GetSetting("POWRS.PaymentLink.ApiKey","");
KeyPassword:= GetSetting("POWRS.PaymentLink.ApiKeySecret","");

S1 := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + LegalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

ResponseSignContract := POST(NeuronAddress + "/Agent/Legal/SignContract",
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

State := select top 1 State from Contracts where ContractId = ContractId;

Link := NeuronAddress + "/Payout/Payout.md?ID=" + Replace(ContractId,"@legal.lab.neuron.vaulter.rs","");
{
    "Link" : Link
}
