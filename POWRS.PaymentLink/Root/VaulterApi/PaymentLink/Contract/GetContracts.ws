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

cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};
template:= "https://" + Gateway.Domain + "/Payout/Payout.md?ID={0}";

list:= Create(System.Collections.Generic.List, System.Object);
tokens:= select * from IoTBroker.NeuroFeatures.Token t where t.Creator = auth.legalId;

foreach token in tokens do 
(
 variables:= token.GetCurrentStateVariables();
 list.Add({
        "TokenId": token.TokenId,
        "CanCancel": exists(cancelAllowedStates[s.State]),
        "IsActive": !exists(doneStates[s.State]),
        "Paylink": Replace(template, "{0}", Before(token.OwnershipContract, "@")),
        "Created": token.Created.ToString("s"),
        "State": variables.State,
        "Variables": variables.VariableValues
        });
);
)
catch
(
 InternalServerError(Exception.Message)
);

Return(list);