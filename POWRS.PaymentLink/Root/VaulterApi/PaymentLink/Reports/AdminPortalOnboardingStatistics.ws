SessionUser := Global.ValidateAgentApiToken(false, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo)),
	"organizationList": Required(String(POrganizationList))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "AdminPortalOnboardingStatistics.ws";
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

try
(
	Log.Debug("Posted: " + Str(Posted), logObject, logActor, logEventID, null);
	
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);
	
	filterByCreators := POrganizationList != "";
	
	currentMethod := "Collecting filter criteria";
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);
		
	currentMethod := "getting data from broker accounts and onboardings";
	brokerAccounts := 
		Select UserName, EMail, Created, Enabled
		from BrokerAccounts
		where Created >= DTDateFrom and Created < DTDateTo
		order by UserName;
			
	responseList := Create(System.Collections.Generic.List, System.Object);
	
	Log.Debug("starting foreach account in brokerAccounts", logObject, logActor, logEventID, null);
	foreach account in brokerAccounts do
	(
		comment := "We need to check all record from onboarding, not just thos limited to filter properties";
		if(not exists(select top 1 UserName from GeneralCompanyInformations where UserName = Str(account[0])))then
		(	
			partnerName := "";
			onboardingCompleted := select top 1 Created.Date from IoTBroker.Legal.Identity.LegalIdentity where Account = account[0] and State = "Approved" order by Created desc;

			obj := {
				PartnerName: account[0],
				RegistrationDate: account[2],
				RegistrationInactivity: Days(Now.Date - account[2].Date),
				OnboardingStarted: null,
				OnboardingLastActivity: null,
				OnboardingCompleted: onboardingCompleted
			};
			responseList.Add(obj);
		);
	);
	
	onboardings := 
		select UserName, ShortName, Created, Updated, DateApproved
		from GeneralCompanyInformations
		where Created >= DTDateFrom and Created < DTDateTo
		order by ShortName;
	
	Log.Debug("starting foreach onboarding in onboardings", logObject, logActor, logEventID, null);
	foreach onboarding in onboardings do 
	(
		
		obj := {
			PartnerName: onboarding[1],
			RegistrationDate: (select top 1 Created.Date from BrokerAccounts where UserName = Trim(onboarding[0])),
			RegistrationInactivity: null,
			OnboardingStarted: onboarding[2],
			OnboardingLastActivity: Days(Now.Date - (onboarding[3] ?? onboarding[2]).Date),
			OnboardingCompleted: onboarding[4]
		};
		responseList.Add(obj);
	);	
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
