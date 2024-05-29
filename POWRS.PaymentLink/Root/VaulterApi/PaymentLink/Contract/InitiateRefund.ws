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
                  "Authorization": "Bearer " + SessionUser.jwt});

Counter:= 0;
responseMessage:= "";
State:= "";

while Counter < 10 and responseMessage == "" do
(
 variables:= token.GetCurrentStateVariables();
 State:= variables.State;
 responseMessage:= select top 1 Value from tokenVariables.VariableValues where Name = "RefundPaymentMessage";
 
 Counter += 1;
 Sleep(1000);
);

)
catch
(
 Log.Error(Exception, null);
 BadRequest(Exception.Message);
);

{
    "canceled" : State == "PaymentCanceled"
}

