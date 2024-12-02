SessionUser := Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "GetOrganizations.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	if(SessionUser.orgName = "") then 
	(
		Error("Your Account don't have defined organization name");
	);
	
	myOrganizations := POWRS.PaymentLink.Models.BrokerAccountRole.GetAllOrganizationChildren(SessionUser.orgName);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

