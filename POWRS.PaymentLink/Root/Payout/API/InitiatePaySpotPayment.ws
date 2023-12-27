({
    "tabId": Required(Str(PTabID)),
    "fromMobilePhone": Required(Bool(PFromMobilePhone))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

ServiceProviderId := "POWRS.Payment.PaySpot.PayspotService.Test";
ServiceProviderType := "POWRS.Payment.PaySpot.PayspotServiceProvider";

SessionToken:=  Global.ValidatePayoutJWT();
PContractId:= SessionToken.Claims.contractId;
PTokenId:= SessionToken.Claims.tokenId;

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

escrowDomain:= "https://" + Gateway.Domain + "/Downloads/EscrowPaylink.xsd";


xmlNote:= "<InitiatePayment xmlns='" + escrowDomain + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "'  tabId='" + PTabID + "' fromMobilePhone='" + PFromMobilePhone + "' buyerBankAccount='none' />";

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