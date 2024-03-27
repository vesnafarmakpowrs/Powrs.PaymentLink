Response.SetHeader("Access-Control-Allow-Origin","*");

SessionUser:= Global.ValidateAgentApiToken(true, false);

try 
(
	PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");
	cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
	doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};
	template:= "https://" + PaylinkDomain + "/Payout.md?ID={0}";
	ResultList:= Create(System.Collections.Generic.List, System.Object);

	objBrokerAccountRole := 
		select top 1 * 
		from POWRS.PaymentLink.Models.BrokerAccountRole 
		where UserName = SessionUser.username;
		
	if(objBrokerAccountRole != null and objBrokerAccountRole.Role == POWRS.PaymentLink.Models.AccountRole.ClientAdmin) then (
		listBrokerAcc :=
			Select *
			from POWRS.PaymentLink.Models.BrokerAccountRole
			where OrgName = objBrokerAccountRole.OrgName;
	) else (
		listBrokerAcc := Create(POWRS.PaymentLink.Models.BrokerAccountRole);
		listBrokerAcc.UserName := SessionUser.username;
	);
	
	foreach item in listBrokerAcc do (
		creatorJID := item.UserName + "@" + Gateway.Domain;
		tokens := 
			select * 
			from IoTBroker.NeuroFeatures.Token t 
			where t.CreatorJid = creatorJID
			order by Created desc;
		
		foreach token in tokens do (
			tokenVariables := token.GetCurrentStateVariables();
			ResultList.Add({
				"Creator": item.UserName,
				"TokenId": token.TokenId,
				"CanCancel": tokenVariables.State == "PaymentCompleted",
				"IsActive": !exists(doneStates[tokenVariables.State]),
				"Paylink": Replace(template, "{0}", Global.EncodeContractId(token.OwnershipContract)),
				"Created": token.Created.ToString("s"),
				"State": tokenVariables.State,
				"Variables": tokenVariables.VariableValues
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