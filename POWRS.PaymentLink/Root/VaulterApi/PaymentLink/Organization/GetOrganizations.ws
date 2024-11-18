SessionUser := Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "GetOrganizations.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	organizationsList := 
		select ObjectId, OrganizationName 
		from POWRS.PaymentLink.Models.OrganizationContactInformation 
		where OrganizationName != ""
		order by OrganizationName;	
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

