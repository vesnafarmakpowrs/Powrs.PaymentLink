
Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "tokenId":Required(String(PTokenId)),
    "refundAmount":Required(Double(PRefundAmount) >= 50)
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
   token := select top 1 * from IoTBroker.NeuroFeatures.Token t where t.TokenId = PTokenId;
  
    if(token == null) then 
    (
        Error("Token does not exists");
    )
	else if (PRefundAmount > token.Value) then
	(
	    Error("Bigger refund amount than value of purchase");
	);
	
    tokenVariables := token.GetCurrentStateVariables();
    if token.HasStateMachine then
	(
		CurrentState:= token.GetCurrentStateVariables();
		if exists(CurrentState) then
			ContractState:= CurrentState.State;
	);
	
	if (ContractState == "ReleasedFundsToSeller" || ContractState == "AwaitingforRefundPayment") then
	(
		domain:= "https://" + Gateway.Domain;
		namespace:= domain + "/Downloads/EscrowPaylinkRS.xsd";
		xmlNote := "<SetUpRefund xmlns='" + namespace + "' refundAmount='" + PRefundAmount.ToString() +"' />";
        PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");

		xmlNoteResponse := POST(domain + "/Agent/Tokens/AddXmlNote",
                 {
                    "tokenId": token.TokenId,
	                "note":xmlNote,
	                "personal":false
                  },
		          {"Accept" : "application/json",
                  "Authorization": "Bearer " + SessionUser.jwt});
    
		{
			"Link" : PaymentLinkAddress + "/" + "RefundPayoutIPS.md?ID=" + Global.EncodeContractId(token.OwnershipContract)
		}
	)
	else
	(
		{
            "Right now can't be initiated refund because contract is in " + ContractState
        }
	);
)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
