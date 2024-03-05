
SessionUser:= Global.ValidateAgentApiToken(true, false);

try
(
	sessionUserBrokerAcc := 
		select top 1 *
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = SessionUser.username;
	
	if(sessionUserBrokerAcc == null) then (
		Error("Session user don't have broker role");
	);
	
	if(sessionUserBrokerAcc.Role != POWRS.PaymentLink.Models.AccountRole.SuperAdmin &&
		sessionUserBrokerAcc.Role != POWRS.PaymentLink.Models.AccountRole.Client
	) then (
		Error("Logged user don't have authorization to create sub user");
	);
	
	sessionUserRoleInt := POWRS.PaymentLink.Models.EnumHelper.GetIndexByName(POWRS.PaymentLink.Models.AccountRole, sessionUserBrokerAcc.Role.ToString());
	myRoleDictionary := POWRS.PaymentLink.Models.EnumHelper.ListAllSubValues(POWRS.PaymentLink.Models.AccountRole, sessionUserRoleInt);
)
catch
(
	Log.Error("Unable to get new user roles: " + Exception.Message, "", "", null);
	BadRequest(Exception.Message);
);	

Return(myRoleDictionary);
