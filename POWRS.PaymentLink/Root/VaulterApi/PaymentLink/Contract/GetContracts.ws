SessionUser:= Global.ValidateAgentApiToken(true, false);

logObject := SessionUser.username;
logEventID := "GetContracts.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try 
(
	if(exists(Posted.DateFrom) and !System.String.IsNullOrWhiteSpace(Posted.DateFrom) and
		exists(Posted.DateTo) and !System.String.IsNullOrWhiteSpace(Posted.DateTo))then
	(
		dateFormat:= "dd/MM/yyyy";
		DTDateFrom := System.DateTime.ParseExact(Posted.DateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := System.DateTime.ParseExact(Posted.DateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := DTDateTo.AddDays(1);
	)
	else
	(
		DTDateFrom := TodayUtc.AddMonths(-1);
		DTDateTo := TodayUtc.AddDays(1);
	);
	
	filterByToken := false;
	filterTokenID := "";
	if(exists(Posted.TokenId) and !System.String.IsNullOrWhiteSpace(Posted.TokenId))then
	(	
		filterByToken := true;
		filterTokenID := Str(Posted.TokenId);
	);
	 
	PayoutPage := "Payout.md";
    IpsOnly := false;

    businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = SessionUser.username;
    if(businessData != null) then 
    (
      IpsOnly := businessData.IPSOnly;
    );

    if IpsOnly then PayoutPage := "PayoutIPS.md";
		
	PaylinkDomain := GetSetting("POWRS.PaymentLink.PayDomain","");
	cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
	doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};
	template:= "https://" + PaylinkDomain + "/" + PayoutPage + "?ID={0}";
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
		tokens := null;
		
		if(filterByToken)then
		(
			tokens := select * 
				from IoTBroker.NeuroFeatures.Token t 
				where t.CreatorJid = creatorJID
					and TokenId = filterTokenID;
		)
		else(
			tokens := select * 
				from IoTBroker.NeuroFeatures.Token t 
				where t.CreatorJid = creatorJID
					and Created >= DTDateFrom
					and Created < DTDateTo
				order by Created desc;
		);
		
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
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	InternalServerError(Exception.Message)
);

Return(ResultList);