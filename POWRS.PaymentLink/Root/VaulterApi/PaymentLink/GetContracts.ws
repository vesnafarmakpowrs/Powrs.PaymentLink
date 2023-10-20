({
    "jwt":Required(Str(PJwt)),
    "skip":Required(Int(PSkip)),
    "take":Required(Int(PTake))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

auth:= POST("https://" + Gateway.Domain + "/VaulterApi/PaymentLink/VerifyToken.ws", {"jwt": PJwt, "includeInfo": true}, {"Accept": "application/json"});

legalId:= auth.legalId;
userName:= auth.userName;

contracts:= null;
try 
(
 contracts:= select top PTake t.TokenId, s.State, s.VariableValues from NeuroFeatureTokens as t join Contracts as c on c.ContractId = t.CreationContract join StateMachineCurrentStates as s on s.StateMachineId = t.TokenId where t.Creator = legalId order by Created desc offset PSkip;
)
catch
(
 Log.Error(Exception.Message, null);
);


{
 "contracts": contracts
}