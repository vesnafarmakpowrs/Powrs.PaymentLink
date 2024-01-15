({
    "contractId":Required(Str(PContractId)),
    "refundAmount" : Optional(int(PRefundAmount))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionUser:= Global.ValidateAgentApiToken(true, false);

try
(
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
namespace:= domain + "/Downloads/EscrowPaylinkSE.xsd";

AmountToRefund:= exists(PRefundAmount) ? PRefundAmount : TokenValue;
xmlNote := "<ReturnFunds xmlns='" + namespace + "' amountToBeReturned='" + AmountToRefund + "' />";

xmlNoteResponse := POST(domain + "/Agent/Tokens/AddXmlNote",
                 {
                  "tokenId": TokenId,
	              "note":xmlNote,
	              "personal":false
                  },
		 {"Accept" : "application/json",
                  "Authorization": SessionUser.jwt});

{	
    "canceled" : true
}
)
catch
(
 Log.Error(Exception, null);
 BadRequest(Exception.Message, null);
);

