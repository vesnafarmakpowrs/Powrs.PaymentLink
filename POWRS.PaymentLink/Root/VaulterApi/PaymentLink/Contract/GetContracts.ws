Response.SetHeader("Access-Control-Allow-Origin","*");
({
    "DateFrom": Optional(Str(PDateFrom)),
    "DateTo": Optional(Str(PdateTo))
}:=Posted) ??? BadRequest(Exception);
SessionUser:= Global.ValidateAgentApiToken(true, false);
try
(	
	PDateFrom := PDateFrom ?? "";
	PDateTo := PDateTo ?? "";
	dateFormat:= "MM/dd/yyyy";
	if(!IsEmpty(PDateFrom) and !IsEmpty(PDateTo)) then (
		DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := DTDateTo.AddDays(1);
	) else (
		DTDateFrom := System.DateTime.ParseExact("01/01/2023", dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := TodayUtc.AddDays(1);
	);
	
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
				and Created >= DTDateFrom
				and Created < DTDateTo
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