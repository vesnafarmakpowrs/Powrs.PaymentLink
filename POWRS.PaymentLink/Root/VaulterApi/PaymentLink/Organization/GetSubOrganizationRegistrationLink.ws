SessionUser := Global.ValidateAgentApiToken(false, false);

({
    "organizationName": Required(Str(POrganizationName))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "GetSubOrganizationRegistrationLink.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	
	orgName := POrganizationName;

	orgClientType := Select top 1 * from POWRS.PaymentLink.ClientType.Models.OrganizationClientType where OrganizationName = orgName;


)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

