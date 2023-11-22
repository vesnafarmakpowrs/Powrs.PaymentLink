Response.SetHeader("Access-Control-Allow-Origin","*");

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

cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};

contracts:= null;
template:= "https://" + Gateway.Domain + "/Payout/Payout.md?ID={0}";
try 
(
 contracts:= select t.TokenId, s.State, t.Created.ToString("s") as "Created", exists(cancelAllowedStates[s.State]) as CanCancel, !exists(doneStates[s.State]) as IsActive, Replace(template, "{0}", Before(t.OwnershipContract, "@")) as "Paylink", s.VariableValues as 'Variables' from NeuroFeatureTokens as t join StateMachineCurrentStates as s on s.StateMachineId = t.TokenId where t.Creator = auth.legalId order by t.Created DESC;
)
catch
(
 InternalServerError(Exception.Message)
);

contracts;