﻿({
    "tabId": Required(Str(PTabID))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

header:= null;
try
(
    Request.Header.TryGetHeaderField("Authorization", header);
    SessionToken:= ValidateJwt(Replace(header.Value, "Bearer ", ""));

    requestEndPoint:= Split(Str(Request.RemoteEndPoint), ":")[0];
    claimsEndpoint:= Split(SessionToken.Claims.ip, ":")[0];

    if(requestEndPoint != claimsEndpoint) then 
	(
	 Error("");
	);

	PTokenId:= SessionToken.Claims.tokenId;
)
catch
(
    Forbidden("Session token expired or not valid");
);

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

escrowDomain:= "https://" + Gateway.Domain + "/Downloads/EscrowPaylink.xsd";


xmlNote:= "<InitiateCardPayment xmlns='" + escrowDomain + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "'  tabId='" + PTabID + "' />";

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