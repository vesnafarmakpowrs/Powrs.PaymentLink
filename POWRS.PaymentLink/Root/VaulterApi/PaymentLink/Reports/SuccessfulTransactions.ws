Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "SuccessfulTransactions.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];


({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "ips": Required(Bool(PIncludeIps)),
    "cardBrands":Optional(String(PCardBrands)), 
    "filterType": Optional(String(PFitlerType))
}:=Posted) ??? BadRequest(Exception.Message);

try
(
    PFitlerType := PFitlerType ?? "Report";
	PCardBrands := PCardBrands ?? "";
    if(!PIncludeIps and PCardBrands == "") then (
        Error("No payment methods selected");
    );
    
    GetAgentSuccessfullTransactions(SessionUser.username, PDateFrom, PDateTo, PIncludeIps, PCardBrands, PFitlerType);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);