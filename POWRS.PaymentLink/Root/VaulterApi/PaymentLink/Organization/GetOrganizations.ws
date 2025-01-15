SessionUser := Global.ValidateSmartAgentApiToken();

logObject := SessionUser.username;
logEventID := "GetOrganizations.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	myOrganizations := POWRS.PaymentLink.Module.PaymentLinkModule.GetUsernameOrganizations(SessionUser.username);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

