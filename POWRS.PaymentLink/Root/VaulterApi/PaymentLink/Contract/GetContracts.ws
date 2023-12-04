﻿SessionUser:= Global.ValidateAgentApiToken(Request, Response);

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
tokens:= select * from IoTBroker.NeuroFeatures.Token t where t.Creator = SessionUser.legalId;

foreach token in (select * from tokens order by Created desc) do 
(
 variables:= token.GetCurrentStateVariables();
 list.Add({
  "TokenId": token.TokenId,
  "CanCancel": exists(cancelAllowedStates[s.State]),
  "IsActive": !exists(doneStates[s.State]),
  "Paylink": Replace(template, "{0}", Global.EncodeContractId(token.OwnershipContract)),
  "Created": token.Created.ToString("s"),
  "State": variables.State,
  "Variables": variables.VariableValues
 });
);
)
catch
(
 Log.Error(Exception, null);
 InternalServerError(Exception.Message)
);

Return(list);