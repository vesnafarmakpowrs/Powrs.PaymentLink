SessionUser := Global.ValidateSmartAdminApiToken();

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
brokerAccDict := {}; comment:= "We are creating a dictionary because it is the fastest way to iterate through the data, plus List functions don't work";
onboardingDict := {}; 

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

GetBrokerAccounts(POrganizationList) := (
	brokerAccBuilder := Create(System.Text.StringBuilder);
	brokerAccBuilder.AppendLine("Select UserName, EMail, Created, Enabled");
	brokerAccBuilder.AppendLine("from BrokerAccounts");
	brokerAccBuilder.AppendLine("where Created >= DTDateFrom and Created < DTDateTo");
	if(POrganizationList != "")then
	(
		brokerAccBuilder.AppendLine("and UserName = myUser");
		brokerAccBuilder.AppendLine("order by UserName");
		users := Global.GetUsersForOrganization(POrganizationList, false);
		
		foreach myUser in users do 
		(
			SelectBrokerAccounts(brokerAccBuilder, myUser);
		);
	)
	else
	(
		brokerAccBuilder.AppendLine("order by UserName");
		SelectBrokerAccounts(brokerAccBuilder, "");
	);
	return (1); 
);
SelectBrokerAccounts(brokerAccBuilder, myUser) := (
	brokerAccs:= Evaluate(Str(brokerAccBuilder));
	foreach acc in brokerAccs do 
	(
		if(!brokerAccDict.ContainsKey(acc[0]))then
		(
			obj := {
				UserName: acc[0],
				EMail: acc[1],
				Created: acc[2],
				Enabled: acc[3]
			};
			brokerAccDict.Add(acc[0], obj);
		);
	);
	return (1); 
);

GetOnbordingsInfo(POrganizationList) := (
	onboardingsBuilder := Create(System.Text.StringBuilder);
	onboardingsBuilder.AppendLine("select UserName, ShortName, Created, Updated, DateApproved");
	onboardingsBuilder.AppendLine("from GeneralCompanyInformations");
	onboardingsBuilder.AppendLine("where Created >= DTDateFrom and Created < DTDateTo");

	start := Now;
	if(POrganizationList != "")then
	(
		onboardingsBuilder.AppendLine("and ShortName = orgName");
		onboardingsBuilder.AppendLine("order by ShortName");
		orgArray := Split(POrganizationList, ",");
		
		foreach orgName in orgArray do 
		(
			SelectOnboardings(onboardingsBuilder, orgName);
		);
	)
	else
	(
		onboardingsBuilder.AppendLine("order by ShortName");
		SelectOnboardings(onboardingsBuilder, "");
	);
	finish := Now;
	return (1); 
);
SelectOnboardings(onboardingsBuilder, orgName) := (
	onboardings:= Evaluate(Str(onboardingsBuilder));
	foreach item in onboardings do 
	(
		if(!onboardingDict.ContainsKey(item[1]))then
		(
			obj := {
				UserName: item[0],
				ShortName: item[1],
				Created: item[2],
				Updated: item[3],
				DateApproved: item[4]
			};
			onboardingDict.Add(item[1], obj);
		);
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
		
	currentMethod := "getting data from broker accounts";
	comment:="We need to iterate through broker accounts to identify users who don’t go through the onboarding process.";
	GetBrokerAccounts(POrganizationList);
	currentMethod := "getting data from broker accounts";
	GetOnbordingsInfo(POrganizationList);
	
	responseList := Create(System.Collections.Generic.List, System.Object);
	
	foreach keyValuePair in brokerAccDict do
	(
		comment := "We need to check all record from onboarding, not just thos limited to filter properties";
		account := keyValuePair.Value;
		if(not exists(select top 1 UserName from GeneralCompanyInformations where UserName = Str(account.UserName)))then
		(	
			partnerName := "";
			onboardingCompleted := select top 1 Created.Date from IoTBroker.Legal.Identity.LegalIdentity where Account = account.UserName and State = "Approved" order by Created desc;
			
			comment:= "we show all users that have created an account before the onboarding functionality because, in production, all user records have one-to-one relationship";
			
			obj := {
				PartnerName: account.UserName,
				RegistrationDate: account.Created,
				RegistrationInactivity: Days(Now.Date - account.Created.Date),
				OnboardingStarted: null,
				OnboardingLastActivity: null,
				OnboardingCompleted: onboardingCompleted
			};
			responseList.Add(obj);
		);
	);
	
	foreach keyValuePair in onboardingDict do 
	(
		onboarding := keyValuePair.Value;
		obj := {
			PartnerName: onboarding.ShortName,
			RegistrationDate: (select top 1 Created.Date from BrokerAccounts where UserName = Trim(onboarding.UserName)),
			RegistrationInactivity: null,
			OnboardingStarted: onboarding.Created,
			OnboardingLastActivity: abs(Days(Now.Date - (onboarding.Updated ?? onboarding.Created).Date)),
			OnboardingCompleted: onboarding.DateApproved
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
