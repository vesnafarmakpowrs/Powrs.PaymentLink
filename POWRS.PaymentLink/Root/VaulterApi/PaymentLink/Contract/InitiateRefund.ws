({
    "tokenId":Required(Str(PTokenId))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionUser:= Global.ValidateAgentApiToken(true, false);

try
(
    token := select top 1 * from IoTBroker.NeuroFeatures.Token t where t.TokenId = PTokenId;
    if(token == null) then 
    (
        Error("Token does not exists");
    );

    tokenVariables := token.GetCurrentStateVariables();
    canCancel:= select top 1 Value from tokenVariables.VariableValues where Name = "CanCancel";

    if(canCancel != true) then 
    (
        Error("Unable to initiate refund for the token");
    );

    domain:= "https://" + Gateway.Domain;
    namespace:= domain + "/Downloads/EscrowPaylinkRS.xsd";
    xmlNote := "<CancelPayment xmlns='" + namespace + "' />";

    xmlNoteResponse := POST(domain + "/Agent/Tokens/AddXmlNote",
                 {
                    "tokenId": token.TokenId,
	                "note":xmlNote,
	                "personal":false
                  },
		          {"Accept" : "application/json",
                  "Authorization": SessionUser.jwt});

result:= false;
Counter:= 0;

while result == false and Counter < 5 do
(
 state:= select top 1 State from StateMachineCurrentStates where StateMachineId = Token.TokenId;
 result:= state == "PaymentCanceled";
 
 Counter += 1;
 Sleep(1000);
);

)
catch
(
 Log.Error(Exception, null);
 BadRequest(Exception.Message, null);
);

{
     "canceled" : result
}

