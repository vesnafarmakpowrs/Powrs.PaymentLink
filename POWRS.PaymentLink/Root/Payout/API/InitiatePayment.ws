({
    "tabId": Required(Str(PTabID)),
	"requestFromMobilePhone": Optional(Boolean(PRequestFromMobilePhone)),
	"bankAccount": Optional(Str(PBuyerBankAccount)),
	"bic" :Optional(Str(PBic)),
	"stripe" : Optional(Boolean(PStripePayment)),
	"personalNumber": Required(Str(PPersonalNumber) like "(19|20)?[0-9]{6}[-+]{0,1}[0-9]{4}$")
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionToken:=  Global.ValidatePayoutJWT();
PTokenId:= SessionToken.Claims.tokenId;

normalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize("SE", PPersonalNumber);
isValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid("SE" ,normalizedPersonalNumber);

if(!isValid) then 
(
 BadRequest("Personal number not valid for Sweden.")
);

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

escrowDomain:= "https://" + Gateway.Domain + "/Downloads/EscrowPaylinkSE.xsd";

if (PStripePayment) then
(
   xmlNote:= "<InitiateCardPayment xmlns='" + escrowDomain + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "'  tabId='" + PTabID + "' />";
)else
(
   xmlNote:= "<InitiatePayment xmlns='" + escrowDomain + "' buyerBankAccount='" + PBuyerBankAccount + "' buyEdalerServiceProviderId='" + ServiceProviderId + "' buyEdalerServiceProviderType='" + ServiceProviderType + "' fromMobilePhone='" + PRequestFromMobilePhone + "'  tabId='" + PTabID + "' buyerPersonalNumber='" + normalizedPersonalNumber + "'  />";
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