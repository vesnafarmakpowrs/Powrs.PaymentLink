({
	"contractId":Required(Str(PContractId))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

contractParameters:= select top 1 Parameters from IoTBroker.Legal.Contracts.Contract where ContractId = PContractId;
TokenId:= select top 1 TokenId from NeuroFeatureTokens where OwnershipContract = PContractId;
if(contractParameters == null || System.String.IsNullOrEmpty(TokenId)) then
(
   BadRequest("Parameters or token for given contract do not exists");
);

PUserName := GetSetting("POWRS.PaymentLink.OPPUser","");
PPassword := GetSetting("POWRS.PaymentLink.OPPUserPass","");

Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));

Response := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                      "userName": PUserName,
                      "nonce": Nonce,
	              "signature": Signature,
	              "seconds": 60
                  },
		   {"Accept" : "application/json"});

xmlNote := "<Cancel namespace=\"https://lab.neuron.vaulter.rs/Downloads/EscrowRebnis.xsd\" />";

xmlNoteResponse := POST("https://lab.neuron.vaulter.rs/Agent/Tokens/AddXmlNote",
                 {
                  "tokenId": TokenId,
	              "note":xmlNote.ToString(),
	              "personal":false
                  },
		        {"Accept" : "application/json",
                "Authorization":"Bearer " + Response.jwt});


{	
    "xmlNote" : xmlNoteResponse
}

