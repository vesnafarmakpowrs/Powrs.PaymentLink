({
    "contractId":Required(Str(PContractId)),
    "refundAmount" : Optional(int(PRefundAmount))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Response.SetHeader("Access-Control-Allow-Origin","*");

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

Token := select top 1 TokenId, Value from NeuroFeatureTokens where OwnershipContract = PContractId;
TokenId := Token[0][0];
TokenValue := Token[0][1];

if (PRefundAmount > TokenValue) then
(
   BadRequest("Refund amount can't be bigger than item value ");
);


if(System.String.IsNullOrEmpty(TokenId)) then
(
   BadRequest("Parameters or token for given contract do not exists");
);

domain:= "https://" + Gateway.Domain;
namespace:= domain + "/Downloads/EscrowRebnis.xsd";


if exists(PRefundAmount)  then
(
  xmlNote := "<ReturnFunds xmlns='" + namespace + "' amountToBeReturned='" + PRefundAmount + "' />";
)
else
(
  xmlNote := "<ReturnFunds xmlns='" + namespace + "' amountToBeReturned='" + TokenValue + "' />";
);

xmlNoteResponse := POST(domain + "/Agent/Tokens/AddXmlNote",
                 {
                  "tokenId": TokenId,
	              "note":xmlNote,
	              "personal":false
                  },
		 {"Accept" : "application/json",
                  "Authorization": header.Value});

{	
    "canceled" : true
}

