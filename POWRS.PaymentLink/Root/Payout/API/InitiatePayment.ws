({
        "tabId": Required(Str(PTabID)),
	"tokenId": Required(Str(PTokenId)),
	"requestFromMobilePhone": Optional(Boolean(PRequestFromMobilePhone)),
	"bankAccount": Optional(Str(PBuyerBankAccount)),
	"bic" :Optional(Str(PBic)),
	"stripe" : Optional(Boolean(PStripePayment))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

P:=GetServiceProvidersForBuyingEDaler('SE','SEK');
ServiceProviderId := "";
ServiceProviderType := "";

PStripePayment == null ? PStripePayment:= false;
PRequestFromMobilePhone == null ? PRequestFromMobilePhone:= false;
PBic == null ? PBic := "";
PBuyerBankAccount == null ? PBuyerBankAccount := "";

foreach asp in P do

   if (PStripePayment && Contains(asp.Id,"Stripe") ) then
    (
	  ServiceProviderId := asp.Id;
	  ServiceProviderType := asp.BuyEDalerServiceProvider.Id + ".StripeServiceProvider";
    )
   else if (!PStripePayment && Contains(asp.Id,PBic)) then
    (
	  ServiceProviderId := asp.Id;
	  ServiceProviderType := asp.BuyEDalerServiceProvider.Id + ".OpenPaymentsPlatformServiceProvider";
    );

  
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

if (PStripePayment) then
(
   xmlNote:= "<InitiateCardPayment xmlns='" + escrowDomain + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "'  tabId='" + PTabID + "' />";
)else
(
   xmlNote:= "<InitiatePayment xmlns='" + escrowDomain + "' buyerBankAccount='" + PBuyerBankAccount + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "' fromMobilePhone='" + PRequestFromMobilePhone + "'  tabId='" + PTabID + "' />";
);


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