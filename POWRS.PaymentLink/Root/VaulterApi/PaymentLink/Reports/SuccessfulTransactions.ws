Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, true);

({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "paymentType": Optional(String(PPaymentType)),
    "cardBrands":Optional(String(PCardBrands)), 
    "filterType": Optional(String(PFitlerType))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "SuccessfulTransactions.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    PPaymentType := PPaymentType ?? "";
	PCardBrands := PCardBrands ?? "";
    PFitlerType := PFitlerType ?? "Report";
    
    GetAgentSuccessfullTransactions(SessionUser.username, PDateFrom, PDateTo, PPaymentType, PCardBrands, PFitlerType);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);