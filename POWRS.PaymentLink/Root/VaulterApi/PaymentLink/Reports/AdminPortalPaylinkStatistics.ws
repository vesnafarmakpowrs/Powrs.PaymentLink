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
responsePartnerDict := {}; comment:= "We are creating a dictionary because it is the fastest way to iterate through the data, plus List functions don't work";

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

SelectPaylinksAndProcessStatistics(paylinksBuilder, statisticsBuilder, creator) := (
	PayLinks:= Evaluate(Str(paylinksBuilder));
	Statistics:= Evaluate(Str(statisticsBuilder));
	foreach statistic in Statistics do 
	(
		ProcessSellerDataIntoDict(statistic[0], statistic[1], statistic[2], statistic[3], statistic[4]);
	);
	return (1); 
);

ProcessSellerDataIntoDict(sellerName, nrPaylinks, firstPaylink, latestPaylink, totalPrice) := (
	if(responsePartnerDict.ContainsKey(sellerName))then
	(
		obj := responsePartnerDict[sellerName];
		obj.PaylinksCount += nrPaylinks;
		obj.LatestPaylinkDate := latestPaylink;
		obj.TotalPaylinkValue += totalPrice;				
	)
	else
	(
		obj := {
			PartnerName: sellerName,
			PaylinksCount: nrPaylinks,
			TotalPaylinkValue: totalPrice,
			AveragePaylinkValue: 0,
			FirstPaylinkDate: firstPaylink,
			LatestPaylinkDate: latestPaylink,
			PaylinkFrequency: 0,
			LatestPaylinkDays: 0,
			OnboardingCompleted: DateTime(0001,01,01)
		};
		responsePartnerDict.Add(sellerName, obj);
	);
	return (1); 
);

try
(
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);
	
	filterByCreators := POrganizationList != "";
	
	currentMethod := "Collecting filter criteria";
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);
		
	currentMethod := "prepering response dict";
	paylinksBuilder := Create(System.Text.StringBuilder);
	paylinksBuilder.AppendLine("select TokenId,Updated,");
	paylinksBuilder.AppendLine("((select top 1 Value from 'StateMachineSamples' where StateMachineId=TokenId and Variable='SellerName' order by Timestamp desc) ?? '-') as SellerName,");
	paylinksBuilder.AppendLine("((select top 1 Value from 'StateMachineSamples' where StateMachineId=TokenId and Variable='Price' order by Timestamp desc) ?? 1) as Price ");
	paylinksBuilder.AppendLine("from NeuroFeatureReferences");
	paylinksBuilder.AppendLine("where Updated >= DTDateFrom and Updated < DTDateTo");
	
	statisticsBuilder := Create(System.Text.StringBuilder);
	statisticsBuilder.AppendLine("select SellerName, count(*) NrPaylinks, Min(Updated) First, Max(Updated) Latest, sum(Price) TotalPrice");
	statisticsBuilder.AppendLine("from PayLinks");
	statisticsBuilder.AppendLine("from group by SellerName");
	
	if(filterByCreators)then
	(
		paylinksBuilder.AppendLine("and OwnerJid = creator");
		paylinksBuilder.AppendLine("order by SellerName");
		creators:= Global.GetUsersForOrganization(POrganizationList, true);
		
		foreach creator in creators do 
		(
			SelectPaylinksAndProcessStatistics(paylinksBuilder, statisticsBuilder, creator);
		);
	)
	else
	(
		paylinksBuilder.AppendLine("order by SellerName");
		SelectPaylinksAndProcessStatistics(paylinksBuilder, statisticsBuilder, "");
	);
	
	destroy(paylinksBuilder);
	destroy(statisticsBuilder);
	destroy(PayLinks);
	destroy(Statistics);
	
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
		
		obj.LatestPaylinkDays := Days(Now.Date - obj.LatestPaylinkDate.Date);
		
		generalInfoDateApproved := select top 1 DateApproved from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where ShortName = obj.PartnerName;
		obj.OnboardingCompleted := generalInfoDateApproved ?? DateTime(1,1,1);
		
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
