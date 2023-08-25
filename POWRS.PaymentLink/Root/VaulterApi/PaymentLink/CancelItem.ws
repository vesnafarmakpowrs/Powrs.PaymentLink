({
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword)),
    "contractId":Required(Str(PContractId))
	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

PContractId := PContractId + "@legal." + Waher.IoTGateway.Gateway.Domain;

contractParameters:= select top 1 Parameters from IoTBroker.Legal.Contracts.Contract where ContractId = PContractId;
TokenId:= select top 1 TokenId from NeuroFeatureTokens where OwnershipContract = PContractId;

if(contractParameters == null || System.String.IsNullOrEmpty(TokenId)) then
(
   BadRequest("Parameters or token for given contract do not exists");
);

Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));

Response := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                     "nonce": Nonce,
	                "signature": Signature,
	                "seconds": 5
                  },
		   {"Accept" : "application/json"});

domain:= "https://" + Gateway.Domain;
namespace:= domain + "/Downloads/EscrowRebnis.xsd";
xmlNote := "<Cancel xmlns='" + namespace + "' />";

xmlNoteResponse := POST(domain + "/Agent/Tokens/AddXmlNote",
                 {
                  "tokenId": TokenId,
	              "note":xmlNote,
	              "personal":false
                  },
		        {"Accept" : "application/json",
                "Authorization":"Bearer " + Response.jwt});

{	
    "xmlNote" : xmlNoteResponse
}

