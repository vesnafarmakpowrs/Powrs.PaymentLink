

SessionUser:= Global.ValidateAgentApiToken(true, false);

try(
	objBrokerAccRole := 
		Select top 1 *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = creatorUserName;
	
	if (objBrokerAccRole == null) then (
		Error("Unable to get list of user. Logged user don't have BrokerAccountRole");
	);
	
	if (objBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.SuperAdmin &&
		objBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.Client
	) then (
		Error("Unable to get list of user. Logged user don't have appropriate role.");
	);
	
	if(objBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.SuperAdmin) then (
		listBrokerAcc :=
			Select top 1 *
			from POWRS.PaymentLink.Models.BrokerAccountRole
			order by UserName;
	) else (
		listBrokerAcc :=
			Select top 1 *
			from POWRS.PaymentLink.Models.BrokerAccountRole
			where OrgName = objBrokerAccRole.OrgName
				or ParentOrgName = bjBrokerAccRole.OrgName
			order by UserName;
	);
	
	ResultList := Create(System.Collections.Generic.List, System.Object);
	
	foreach account in (select * from listBrokerAcc) do
	(
		Identity := 
			select top 1 * 
			from IoTBroker.Legal.Identity.LegalIdentity 
			where Account = Contract.Account 
				And State = "Approved";
		
		if (Identity == null) then (
			Identity := 
				select top 1 * 
				from IoTBroker.Legal.Identity.LegalIdentity 
				where Account = Contract.Account 
				order by Created desc;
		);
		
		accFirst := "";
		accLast := ""; 
		accEmail := "";
		
		foreach item in Identity.Properties do (
			if(item.Name == "FIRST") then (
				accFirst := item.Value;
			);
			if(item.Name == "LAST") then (
				accLast := item.Value;
			);
			if(item.Name == "EMAIL") then (
				accEmail := item.Value;
			);
		);
	
		ResultList.Add({
			"UserName": account.UserName,
			"Firs": accFirst,
			"Last": accLast,
			"Email": accEmail,
			"Created": Identity.Created.ToString("s");
			"From": Identity.From.ToString("s"),
			"To": Identity.To.ToString("s"),
			"Role": account.Role.ToString(),
			"IsActive": Identity.State == "Approved"
		});
	);
)
catch(
	Log.Error("Unable to get users: " + Exception.Message, "", "GetUsers", null);
    BadRequest(Exception.Message);	
);

Return (ResultList);