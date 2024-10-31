Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "ReportPayouts.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$")
}:=Posted) ??? BadRequest(Exception.Message);

Try
(
	paymentType := "";
	cardBrands := "";
	fitlerType := "Payout";
	filteredData := GetAgentSuccessfullTransactions(SessionUser.username, PDateFrom, PDateTo, paymentType, cardBrands, fitlerType);
	
	resultList := Create(System.Collections.Generic.List, System.Object);
	currentDay := DateTime(2001, 1, 1);
	currentCurrency := "";
	totalAmount := 0;
	totalFee := 0;
	recodProccessed := true;
	transactionsCount := 0;

	if(filteredData != null and filteredData.Count > 0) then 
	(
		currentDay := filteredData[0].PayoutDate;
		currentCurrency := filteredData[0].Currency;
	);

	foreach payment In filteredData Do
	(
		If ((currentDay!= payment.PayoutDate Or currentCurrency!= payment.Currency)) Then
		(
			resultList.Add({
				"PayoutDate": currentDay,
				"Currency": currentCurrency,
				"TotalAmount": totalAmount,
				"TotalFee": totalFee,
				"transactionsCount": transactionsCount,
				"SellerRecivedAmount" : totalAmount -totalFee
			});
			
			totalAmount := 0;
			totalFee := 0;
			transactionsCount := 0;
			recodProccessed := true;
		);
		
		recodProccessed := false;
		currentDay := payment.PayoutDate;
		currentCurrency := payment.Currency;
		totalAmount += payment.Amount;
		totalFee += payment.SenderFee;
		transactionsCount ++;
	);
	
	If (!recodProccessed) Then
	(
		resultList.Add({
			"PayoutDate": currentDay,
			"Currency": currentCurrency,
			"TotalAmount": totalAmount,
			"TotalFee": totalFee,
			"transactionsCount": transactionsCount,
			"SellerRecivedAmount" : totalAmount -totalFee
		});
	);
		
	resultList;
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);