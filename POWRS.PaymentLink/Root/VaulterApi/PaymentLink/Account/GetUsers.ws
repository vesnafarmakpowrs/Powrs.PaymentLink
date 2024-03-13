SessionUser:= Global.ValidateAgentApiToken(true, false);

try(
	objBrokerAccRole := 
		Select top 1 *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = SessionUser.username;
	
	if (objBrokerAccRole == null) then (
		Error("Unable to get list of user. Logged user don't have BrokerAccountRole");
	);
	
	if (objBrokerAccRole.Role != POWRS.PaymentLink.Models.AccountRole.Client) then (
		Error("Unable to get list of user. Logged user don't have appropriate role.");
	);
	
	listBrokerAcc :=
		Select *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where OrgName = objBrokerAccRole.OrgName
		order by UserName;
	
	ResultList := Create(System.Collections.Generic.List, System.Object);
	
	foreach account in listBrokerAcc do
	(
		accIdentity := 
			select top 1 * 
			from IoTBroker.Legal.Identity.LegalIdentity 
			where Account = account.UserName
				And State = "Approved"
			order by Created desc;
		
		if (accIdentity == null) then (
			accIdentity := 
				select top 1 * 
				from IoTBroker.Legal.Identity.LegalIdentity 
				where Account = account.UserName 
				order by Created desc;
		);
		
		accFirst := "";
		accLast := ""; 
		accEmail := "";
		accState := 0;
		
		if(accIdentity != null) then (
			foreach item in accIdentity.Properties do (
				if(item.Name == "FIRST") then (
					accFirst := item.Value;
				) else if(item.Name == "LAST") then (
					accLast := item.Value;
				) else if(item.Name == "EMAIL") then (
					accEmail := item.Value;
				);
			);
			
			if(accIdentity.State == Waher.Service.IoTBroker.Legal.Identity.IdentityState.Approved) then (
				accState := 1;
			) else if (accIdentity.State == Waher.Service.IoTBroker.Legal.Identity.IdentityState.Rejected) then (
				accState := -1;
			) else (
				accState := 0;
			);
		);
		
		ResultList.Add({
			"UserName": account.UserName,
			"First": accFirst,
			"Last": accLast,
			"Email": accEmail,
			"Role": account.Role.ToString(),
			"State": accState
		});
	);
)
catch(
	Log.Error("Unable to get users: " + Exception.Message, "", "GetUsers", null);
    BadRequest(Exception.Message);	
);

Return (ResultList);