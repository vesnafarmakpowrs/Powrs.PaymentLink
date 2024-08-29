Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "ReportPayouts.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$")
}:=Posted) ??? BadRequest(Exception.Message);

try
(
	dateFormat:= "dd/MM/yyyy";
	ParsedFromDate:= System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	ParsedToDate:= System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	ParsedToDate := ParsedToDate.AddDays(1);
	
	if(ParsedFromDate >= ParsedToDate) then
	(
		Error("From date must be before to date");
	);
	
	Creators:= Global.GetUserHierarchy(SessionUser.username);
	filteredData:= 
		select pp.PayoutDate
			, s.VariableValues
			, pp.Amount
			, pp.SenderFee
		from POWRS.Networking.PaySpot.Data.PayspotPayment pp 
			join NeuroFeatureTokens t on t.TokenId = pp.TokenId
			join StateMachineCurrentStates s on s.StateMachineId == pp.TokenId
		where pp.PayoutDate >= ParsedFromDate and
			pp.PayoutDate < ParsedToDate and
			pp.Result like "00" and
			t.CreatorJid IN Creators
		order by PayoutDate desc;
	
	resultList := Create(System.Collections.Generic.List, System.Object);
	currentDay := DateTime(2001, 1, 1);
	currentCurrency := "";
	totalAmount := 0;
	totalFee := 0;
	isFirst := true;
	
	foreach payment in filteredData do
	(
		variables:=  payment[1];
		if(variables != null and variables.Length > 0) then
		(
			currency := select top 1 Value from variables where Name = "Currency";
			amount := payment[2] == null ? 0 : payment[2];
			fee := payment[3] == null ? 0 : Double(payment[3]);
			
			if((currentDay != payment[0] or currentCurrency != currency) and !isFirst)then
			(
				resultList.Add({
					"PayoutDate": currentDay,
					"Currency": currentCurrency,
					"TotalAmount": totalAmount,
					"TotalFee": totalFee,
					"SellerRecivedAmount" : totalAmount - totalFee
				});
				
				totalAmount := 0;
				totalFee := 0;
			);
			
			isFirst := false;
			currentDay := payment[0];
			currentCurrency := currency;
			totalAmount += amount;
			totalFee += fee;
		);
	);
	
	if(!isFirst)then
	(
		resultList.Add({
			"PayoutDate": currentDay,
			"Currency": currentCurrency,
			"TotalAmount": totalAmount,
			"TotalFee": totalFee,
			"SellerRecivedAmount" : totalAmount - totalFee
		});
	);
		
	resultList;
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);