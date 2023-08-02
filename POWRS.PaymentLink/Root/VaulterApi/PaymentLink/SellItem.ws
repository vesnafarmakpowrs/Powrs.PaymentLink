
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
    "callbackUrl":Optional(String(PCallbackUrl))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");


Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));


Response := POST("https://lab.neuron.vaulter.rs/Agent/Account/Login",
                 {
                  "userName": PUserName,
                  "nonce": Nonce,
	              "signature": Signature,
	              "seconds": 60
                  },
		{"Accept" : "application/json"});

Token := "Bearer " + Response.jwt;

t:= "2c5cb3b2-b0a0-95e5-b803-01427d96a9cc@legal.lab.neuron.vaulter.rs";
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
        "BuyerPersonalNum":PBuyerPersonalNum
    });


LegalIdentity :=select top 1 * from IoTBroker.Legal.Identity.LegalIdentity I where I.Account = PUserName order by Created desc ;

LegalId := LegalIdentity.Id;
Nonce := Base64Encode(RandomBytes(32));

LocalName := "ed448";
Namespace := "urn:ieee:iot:e2e:1.0";
KeyId := "*********";
KeyPassword:= "********";

S1 := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + LegalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

ResponseSignContract := POST("https://lab.neuron.vaulter.rs/Agent/Legal/SignContract",
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

Link := "https://lab.neuron.vaulter.rs/Payout/Payout.md?ID=" + Replace(ContractId,"@legal.lab.neuron.vaulter.rs","");
{
    "Link" : Link
}
