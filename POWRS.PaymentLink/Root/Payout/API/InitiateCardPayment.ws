({
         "tabId": Required(Str(PTabID)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"tokenId": Required(Str(PTokenId)),
        "bankAccount": Required(Str(PBankAccount))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");


ServiceProviderId := "TAG.Payments.Stripe.StripeService.Test";
ServiceProviderType := "TAG.Payments.Stripe.StripeServiceProvider";

PUserName := GetSetting("POWRS.PaymentLink.OPPUser","");
PPassword := GetSetting("POWRS.PaymentLink.OPPUserPass","");

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

escrowDomain:= "https://" + Gateway.Domain + "/Downloads/EscrowRebnis.xsd";


xmlNote:= "<InitiatePayment xmlns='" + escrowDomain + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "' fromMobilePhone='" + PRequestFromMobilePhone + "'  tabId='" + PTabID + "' buyerBankAccount='" + PBankAccount + "' />";

xmlNoteResponse := POST(NeuronAddress + "/Agent/Tokens/AddXmlNote",
                 {
                  "tokenId": PTokenId,
	              "note":xmlNote,
	              "personal":false
                  },
		        {"Accept" : "application/json",
                "Authorization":"Bearer " + R.jwt});
{
  "OK": true
}