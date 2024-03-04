Response.SetHeader("Access-Control-Allow-Origin","*");

SessionUser:= Global.ValidateAgentApiToken(true, false);

contracts:= null;
PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");
try 
(
	cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
	doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};
	template:= "https://" + PaylinkDomain + "/Payout.md?ID={0}";

	ResultList:= Create(System.Collections.Generic.List, System.Object);

	creatorJid:= SessionUser.username + "@" + Gateway.Domain;
	tokens:= select * from IoTBroker.NeuroFeatures.Token t where  t.CreatorJid = creatorJid;

	foreach token in (select * from tokens order by Created desc) do
	(
		tokenVariables := token.GetCurrentStateVariables();
		if(tokenVariables.VariableValues.Length > 0) then (
			ResultList.Add({
				"TokenId": token.TokenId,
				"CanCancel": tokenVariables.State == "PaymentCompleted",
				"IsActive": !exists(doneStates[tokenVariables.State]),
				"Paylink": Replace(template, "{0}", Global.EncodeContractId(token.OwnershipContract)),
				"Created": token.Created.ToString("s"),
				"State": tokenVariables.State,
				"Variables": tokenVariables.VariableValues
			});
		)else (
			ResultList.Add({
				"TokenId": token.TokenId,
				"CanCancel": false, 
				"IsActive": false,
				"Paylink": Replace(template, "{0}", Global.EncodeContractId(token.OwnershipContract)),
				"Created": token.Created.ToString("s"),
				"State": "",
				"Variables": token.Tags
			});
		);
	);
)
catch
(
 Log.Error(Exception, null);
 InternalServerError(Exception.Message)
);

Return(ResultList);