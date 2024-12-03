SessionUser := Global.ValidateAgentApiToken(false, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo)),
	"organizationList": Required(String(POrganizationList))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "AdminPortalPaylinkStatistics.ws";
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

try
(	
	Log.Debug("Posted: " + Str(Posted), logObject, logActor, logEventID, null);
	
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);
	
	filterByCreators := POrganizationList != "";
	
	currentMethod := "Collecting data";
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);
		
	sqlQueryBuilder := Create(System.Text.StringBuilder);
	sqlQueryBuilder.AppendLine("select CreatorJid, TokenId, Created ");
	sqlQueryBuilder.AppendLine("from NeuroFeatureTokens ");
	sqlQueryBuilder.AppendLine("where Created >= DTDateFrom and Created < DTDateTo ");
	if(filterByCreators)then
	(
		Creators:= Global.GetUsersForOrganization(POrganizationList);
		sqlQueryBuilder.AppendLine("and CreatorJid IN Creators ");
	);
	
	neuroFeatureTokenList := Evaluate(Str(sqlQueryBuilder));
	destroy(sqlQueryBuilder);
	
	currentMethod := "prepering response dict";
	responsePartnerDict := Create(System.Collections.Generic.Dictionary, System.String, System.Object);		
	counter := 0;
	foreach token in neuroFeatureTokenList do 
	(
		smVariableValues := select top 1 VariableValues
			from StateMachineCurrentStates
			where StateMachineId = token[1];
	
		if(smVariableValues != null and smVariableValues.Length > 0)then
		(
			sellerName := select top 1 Value from smVariableValues where Name = "SellerName";
			price := select top 1 Value from smVariableValues where Name = "Price";
			created := token[2];
			
			sellerName := sellerName ?? "-";
			price := price ?? 1;
			
			if(responsePartnerDict.ContainsKey(sellerName))then
			(
				obj := responsePartnerDict[sellerName];
				obj.PaylinksCount ++;
				obj.LatestPaylinkDate := created;
				obj.TotalPaylinkValue += price;				
			)
			else
			(
				obj := {
					Partnername: sellerName,
					PaylinksCount: 1,
					TotalPaylinkValue: price,
					AveragePaylinkValue: 0,
					FirstPaylinkDate: created,
					LatestPaylinkDate: created,
					PaylinkFrequency: 0					
				};
				responsePartnerDict.Add(sellerName, obj);
			);
		);
	);
	Destroy(neuroFeatureTokenList);
	
	currentMethod := "aggregating data";
	responseList := Create(System.Collections.Generic.List, System.Object);
	foreach item in responsePartnerDict do
	(
		obj := item.Value;
		obj.AveragePaylinkValue := obj.TotalPaylinkValue / obj.PaylinksCount;
		if(obj.PaylinksCount > 1) then
		(
			obj.PaylinkFrequency := Days(obj.LatestPaylinkDate - obj.FirstPaylinkDate) / (obj.PaylinksCount - 1);
		);
		
		responseList.Add(obj);
	);
	
	Destroy(responsePartnerDict);
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
