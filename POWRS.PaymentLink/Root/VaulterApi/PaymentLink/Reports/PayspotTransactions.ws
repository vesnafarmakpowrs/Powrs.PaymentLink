Response.SetHeader("Access-Control-Allow-Origin", "*");
SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "PaySpotTransactions.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
	"organizationList": Required(String(POrganizationList)),
	"id": Required(String(PId))
}:=Posted) ??? BadRequest(Exception.Message);
try
(
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);

	filterByCreators := POrganizationList != "";
	filterByOrderID := PId != "";
	
	sqlQuery := "Select TokenId, OrderId, OrderReference, PayspotTransactionId, DateCreated, ExpectedPayoutDate, PayoutDate, Amount, SenderFee ";
	sqlQuery += "from PayspotPayments ";
	if(filterByCreators) then
	(
		sqlQuery += " pp";
		sqlQuery += "join NeuroFeatureTokens t on t.TokenId = pp.TokenId ";
	);
	sqlQuery += "where DateCreated >= DTDateFrom and DateCreated < DTDateTo and Result='00' and (RefundedAmount = null or RefundedAmount = 0) ";
	
	if(filterByOrderID) then
	(
		sqlQuery += "and TokenId = '" + PId + + "' or PayspotOrderId = '" + PId + "' or BankTransactionId = '" + PId + "') ";
	);
	
	if(filterByCreators) then
	(
		Creators:= Global.GetUsersForOrganization(POrganizationList);
		sqlQuery += "and t.CreatorJid IN Creators ";
	);
	
	Log.Debug("Query: " + sqlQuery, null);

	OrderList := Evaluate(sqlQuery);

	ReponseDict := Create(System.Collections.Generic.List, System.Object);
	foreach order in OrderList do (
		Token:= select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId = order[0];	
		Variables:= Token.GetCurrentStateVariables().VariableValues ??? null;

		if(Token != null and Variables != null) then 
		(
			SellerAccount :=  Split(Token.CreatorJid, "@")[0];
			RemoteId:= select top 1 Value from Variables where Name = "RemoteId";
			SmsCounter:= select top 1 Value from Variables where Name = "SMSCounter";
			EmailCounter:= select top 1 Value from Variables where Name = "EmailCounter";
			fee := order[8] == null ? 0 : Double(order[8]);
			amount:= order[7] == null ? 0 : order[7];

			ReponseDict.Add({
				"TokenId": order[0],
				"OrderId": order[1],
				"OrderReference": order[2],
				"PayspotTransactionId": order[3],
				"DateCreated": order[4],
				"ExpectedPayoutDate": order[5],
				"PayoutDate" :  order[6],
				"Amount": amount,
				"SenderFee": fee,
				"SellerRecivedAmount" : Dbl(amount)-fee,
				"Seller" :  SellerAccount,
				"RemoteId": RemoteId,
				"SMSCounter": SmsCounter, 
				"EmailCounter": EmailCounter
			});
		);	   
	);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);