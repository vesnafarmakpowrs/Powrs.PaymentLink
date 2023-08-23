
if !exists(Posted) then BadRequest("No payload.");

({
    "userName": Required(String(PUserName)),
    "password": Required(String(PPassword)),
    "keyId" : Required(String(PKeyId)),
    "keyPassword" : Required(String(PKeyPassword)),
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


Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));


R := POST("https://" + Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                  "userName": PUserName,
                  "nonce": Nonce,
	              "signature": Signature,
	              "seconds": 60
                  },
		{"Accept" : "application/json"});

Token := "Bearer " + R.jwt;

t:= "2c779265-831b-a0b7-3414-c04ca7e943a1@legal.neuron.vaulter.se";
TemplateId:="2c4be7d4-32ae-033a-1022-ff6e374fa7f6@legal.lab.neuron.vaulter.rs";

Contract:=CreateContract(PUserName,t, "Public",
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

S1 := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + PKeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(PKeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + LegalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

ResponseSignContract := POST("https://" + Waher.IoTGateway.Gateway.Domain + "/Agent/Legal/SignContract",
                             {
	                        "keyId": PKeyId,
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

Link := "https://" + Waher.IoTGateway.Gateway.Domain + "/Payout/Payout.md?ID=" + Replace(ContractId,"@legal." + Waher.IoTGateway.Gateway.Domain,"");
{
    "Link" : Link
}
