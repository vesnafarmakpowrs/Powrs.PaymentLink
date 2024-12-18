Response.SetHeader("Access-Control-Allow-Origin", "*");
SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "PaySpotTransactions.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

({
    "from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo)),
	"organizationList": Required(String(POrganizationList)),
	"id": Required(String(PId))
}:=Posted) ??? BadRequest(Exception.Message);

currentMethod := "";
errors:= Create(System.Collections.Generic.List, System.String);
responseList := Create(System.Collections.Generic.List, System.Object);

ValidatePostedData(Posted) := (
	if(!Global.RegexValidation(Posted.from, "DateDDMMYYYY", "")) then
	(
		errors.Add("from");
	);
	if(!Global.RegexValidation(Posted.to, "DateDDMMYYYY", "")) then
	(
		errors.Add("to");
	);
	if(!System.String.IsNullOrWhiteSpace(Posted.organizationList))then
	(
		myOrganizations := POWRS.PaymentLink.Models.BrokerAccountRole.GetAllOrganizationChildren(SessionUser.orgName);
		organizationArray := Split(Posted.organizationList, ",");
		foreach item in organizationArray do
		(
			if(myOrganizations.Contains(item) == false) then
			(
				errors.Add("organizationName:" + item);
			);
		);
	);
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);
	
	return (1); 
);

SelectPaylinksAndProcessRecords(sqlQueryBuilder, creator) := (
	orderList:= Evaluate(Str(sqlQueryBuilder));
	foreach order in orderList do 
	(
		if(order[9] = null or order[9] = 0) then 
		(
			fee := order[8] == null ? 0 : Double(order[8]);
			amount:= order[7] == null ? 0 : order[7];

			responseList.Add({
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
				"SellerName" :  order[10]
			});
		);
	);
	return (1); 
);

try
(
	timeStart := Now;
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);

	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);

	filterByCreators := POrganizationList != "";
	filterByOrderID := PId != "";
	
	sqlQueryBuilder := Create(System.Text.StringBuilder);	
	sqlQueryBuilder.AppendLine("Select TokenId, OrderId, OrderReference, PayspotTransactionId, DateCreated, ExpectedPayoutDate, PayoutDate, Amount, SenderFee, RefundedAmount");
	sqlQueryBuilder.AppendLine(",((select top 1 Value from 'StateMachineSamples' where StateMachineId=t.TokenId and Variable='SellerName' order by Timestamp desc) ?? '-') as SellerName");
	sqlQueryBuilder.AppendLine("from PayspotPayments pp");
	sqlQueryBuilder.AppendLine("join NeuroFeatureReferences t on t.TokenId = pp.TokenId");
	
	if(filterByOrderID) then
	(
		sqlQueryBuilder.AppendLine("where (TokenId = PId or OrderId = PId or PayspotOrderId = PId or BankTransactionId = PId)");
	)
	else
	(
		sqlQueryBuilder.AppendLine("where DateCreated >= DTDateFrom and DateCreated < DTDateTo and Result='00'" );
	);
	
	if(filterByCreators) then
	(
		creators:= Global.GetUsersForOrganization(POrganizationList, true);
		sqlQueryBuilder.AppendLine("and t.OwnerJid = creator");
		foreach creator in creators do
		(
			SelectPaylinksAndProcessRecords(sqlQueryBuilder, creator);
		);
	)
	else
	(
		SelectPaylinksAndProcessRecords(sqlQueryBuilder, "");
	);	
	destroy(sqlQueryBuilder);
	
	timeFinish := Now;
)
catch
(
	Log.Error("Error: " + Exception.Message + "\ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		NotAcceptable(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);

return (responseList);