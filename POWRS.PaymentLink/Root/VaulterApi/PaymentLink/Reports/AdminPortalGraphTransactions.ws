SessionUser := Global.ValidateSmartAdminApiToken();

if !exists(Posted) then BadRequest("No payload.");

({
	"from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "AdminPortalGraphTransactions.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

currentMethod := "";
errors:= Create(System.Collections.Generic.List, System.String);

ValidatePostedData(Posted) := (
	if(!Global.RegexValidation(Posted.from, "DateDDMMYYYY", "")) then
	(
		errors.Add("from");
	);
	if(!Global.RegexValidation(Posted.to, "DateDDMMYYYY", "")) then
	(
		errors.Add("to");
	);
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);
	
	return (1); 
);


try
(
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);
	
	currentMethod := "Collecting filter criteria";
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);
		
		
	dayDiff := Days(DTDateTo - DTDateFrom);
	rnd := Create(System.Random);
	graphType := "";
	responseList := Create(System.Collections.Generic.List, System.Object);
	
	if(dayDiff < 32)then 
	(
		graphType := "Day";
		FOR i := Day(DTDateFrom) TO Day(DTDateTo) STEP 1 DO
		(
			responseList.Add(
				{
					name: i,
					value: rnd.Next(5, 100)
				}
			);
		);
	)
	else if(dayDiff < 366) then
	(
		graphType := "Month";
		FOR i := Month(DTDateFrom) TO Month(DTDateTo) STEP 1 DO
		(
			responseList.Add(
				{
					name: i,
					value: rnd.Next(1000, 10000)
				}
			);
		);
	)
	else
	(
		graphType := "Year";
		FOR i := Year(DTDateFrom) TO Year(DTDateTo) STEP 1 DO
		(
			responseList.Add(
				{
					name: i,
					value: rnd.Next(10000, 100000)
				}
			);
		);
	);
		
	res := {
		graphType: graphType,
		data: responseList
	};
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
