SessionUser := Global.ValidateAgentApiToken(false, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo)),
	"organizationList": Required(String(POrganizationList)),
	"topicFilterType": Required(String(PTopicFilterType)),
	"topicFilterCondition": Required(String(PTopicFilterCondition)),
	"topicFilterNumber": Required(Int(PTopicFilterNumber))	
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
	
	if(!System.Enum.IsDefined(POWRS.PaymentLink.Enums.Reports.TopicFilter, Posted.topicFilterType))then
	(
		errors.Add("topicFilterType");
	);
	if(!System.String.IsNullOrWhiteSpace(Posted.topicFilterType) and 
		Posted.topicFilterType != "NoFilter" and
		!System.Enum.IsDefined(POWRS.PaymentLink.Enums.Reports.TopicFilterCondition, Posted.topicFilterCondition))then
	(
		errors.Add("topicFilterCondition");
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
	
	currentMethod := "Collecting data";
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);

	responsePartnerDict := Create(System.Collections.Generic.Dictionary, System.String, System.Object);				
	creatorsJIDDict := Create(System.Collections.Generic.Dictionary, System.String, System.String);				
	
	filterByOrgName := false;
	if(POrganizationList != "")then
	(
		filterByOrgName := true;
		organizationArray := Split(POrganizationList, ",");
		foreach item in organizationArray do
		(
			listBrokerAcc :=
				Select *
				from POWRS.PaymentLink.Models.BrokerAccountRole
				where OrgName = item;
				
			foreach brokerAcc in listBrokerAcc do
			(
				creatorsJIDDict.Add(brokerAcc.UserName + "@" + Gateway.Domain, item);
			);
		);		
	);
	
	Log.Debug("creatorsJIDDict: " + Str(creatorsJIDDict), logObject, logActor, logEventID, null);
	
	neuroFeatureTokenList := 
		select * 
		from IoTBroker.NeuroFeatures.Token
		where Created >= DTDateFrom
			and Created < DTDateTo;
			
	currentMethod := "prepering response dict";
	counter := 0;
	foreach token in neuroFeatureTokenList do 
	(
		processRecord := true;
		if(filterByOrgName)then
		(
			if(!creatorsJIDDict.ContainsKey(token.CreatorJid))then
			(
				processRecord := false;
			);
		);
		
		if(processRecord)then
		(
			tokenVariables := token.GetCurrentStateVariables();			
			sellerName := select top 1 Value from tokenVariables.VariableValues where Name = "SellerName";
			if(sellerName != null)then
			(
				price := select top 1 Value from tokenVariables.VariableValues where Name = "Price";
			
				if(responsePartnerDict.ContainsKey(sellerName))then
				(
					obj := responsePartnerDict[sellerName];
					obj.PaylinksCount ++;
					obj.LatestPaylinkDate := token.Created;
					obj.TotalPaylinkValue += price;				
				)
				else
				(
					obj := {
						Partnername: sellerName,
						PaylinksCount: 1,
						TotalPaylinkValue: price,
						AveragePaylinkValue: 0,
						FirstPaylinkDate: token.Created,
						LatestPaylinkDate: token.Created,
						PaylinkFrequency: 0					
					};
					responsePartnerDict.Add(sellerName, obj);
				);
			);
		);
	);
	
	Destroy(neuroFeatureTokenList);
	Destroy(creatorsJIDDict);
	
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
