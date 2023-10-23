({
    "contractId":Required(Str(PContractId))	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Jwt:= null;
try
(
header:= null;
Request.Header.TryGetHeaderField("Authorization", header);
Jwt:= header.Value;
auth:= POST("https://" + Gateway.Domain + "/VaulterApi/PaymentLink/VerifyToken.ws", 
            {"includeInfo": false}, {"Accept": "application/json", "Authorization": header.Value});
)
catch
(
  Forbidden("Token not valid");
);

PContractId := PContractId + "@legal." + Waher.IoTGateway.Gateway.Domain;
TokenId:= select top 1 TokenId from NeuroFeatureTokens where OwnershipContract = PContractId;

if(System.String.IsNullOrEmpty(TokenId)) then
(
   BadRequest("Parameters or token for given contract do not exists");
);

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
                "Authorization":"Bearer " + Jwt});

{	
    "canceled" : true
}

