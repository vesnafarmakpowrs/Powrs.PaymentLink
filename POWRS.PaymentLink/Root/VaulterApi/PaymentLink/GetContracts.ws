({
  "skip":Required(Int(PSkip) >= 0),
  "take":Required(Int(PTake))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

header:= null;
try
(
    Request.Header.TryGetHeaderField("Authorization", header);
    auth:= POST("https://" + Gateway.Domain + "/VaulterApi/PaymentLink/VerifyToken.ws", 
            {"includeInfo": true}, {"Accept": "application/json","Authorization": header.Value});
)
catch
(
   Forbidden("Token not valid");
);

if(PTake < 0) then 
(
 PTake:= System.Int16.MaxValue;
);

cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};

contracts:= null;
try 
(
 contracts:= select top PTake t.TokenId, s.State, t.Created, exists(cancelAllowedStates[s.State]) as CanCancel, !exists(doneStates[s.State]) as IsActive,  s.VariableValues as 'Variables' from NeuroFeatureTokens as t join StateMachineCurrentStates as s on s.StateMachineId = t.TokenId where t.Creator = auth.legalId order by t.Created DESC offset PSkip;
)
catch
(
 Log.Error(Exception.Message, null);
);

Response.SetHeader("Access-Control-Allow-Origin","*");

contracts;