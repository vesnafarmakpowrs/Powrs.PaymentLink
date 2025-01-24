SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "SubmitOnboardingData.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

errors:= Create(System.Collections.Generic.List, System.String);
currentMethod := "";

GetPreciseErrors(onBoardingData):=(
	if(!onBoardingData.GeneralCompanyInformation.IsCompleted())then
	(
		errors.Add("GeneralCompanyInformation");
	);
	if(!onBoardingData.CompanyStructure.IsCompleted())then
	(
		errors.Add("CompanyStructure");
	);
	if(!onBoardingData.BusinessData.IsCompleted())then
	(
		errors.Add("BusinessData");
	);
	
	if(errors.Count > 0)then
	(
		Error(errors);
		return (0);
	)else
	(
		return(1);
	);	
);

ApplyForLeglalID(onBoardingData):=(
	accountRole := 
		Select top 1 * 
		from POWRS.PaymentLink.Models.BrokerAccountRole
		where UserName = SessionUser.username;

	accountRole.OrgName:= onBoardingData.GeneralCompanyInformation.ShortName;
	accountRole.ParentOrgName:= System.String.IsNullOrWhiteSpace(accountRole.ParentOrgName) ? "Powrs" : accountRole.ParentOrgName;
	Waher.Persistence.Database.Update(accountRole);

	Password := 
		select top 1 Password 
		from BrokerAccounts 
		where UserName = SessionUser.username;
		
	firstName := "";
	lastName := "";
	personalNumber := "";
	
	if(onBoardingData.CompanyStructure.OwnerStructure == POWRS.PaymentLink.Onboarding.Enums.OwnerStructure.Person)then
	(
		personalNumber := onBoardingData.GeneralCompanyInformation.LegalRepresentatives[0].PersonalNumber;
		fullNameArray := Split(onBoardingData.GeneralCompanyInformation.LegalRepresentatives[0].FullName, " ");
		if(fullNameArray.Length == 1)then
		(
			firstName := onBoardingData.GeneralCompanyInformation.LegalRepresentatives[0].FullName;
			lastName := " ";
		)
		else 
		(
			firstName := Str(fullNameArray[0]);
			FOR i := 1 TO fullNameArray.Length - 1 STEP 1 DO
			(
				lastName += fullNameArray[i] + ( i != fullNameArray.Length - 1 ? " " : "");
			);
		);		
	)
	else
	(
		personalNumber := onBoardingData.CompanyStructure.Owners[0].PersonalNumber;
		fullNameArray := Split(onBoardingData.CompanyStructure.Owners[0].FullName, " ");
		if(fullNameArray.Length == 1)then
		(
			firstName := onBoardingData.CompanyStructure.Owners[0].FullName;
			lastName := " ";
		)
		else 
		(
			firstName := Str(fullNameArray[0]);
			FOR i := 1 TO fullNameArray.Length - 1 STEP 1 DO
			(
				lastName += fullNameArray[i] + ( i != fullNameArray.Length - 1 ? " " : "");
			);
		);
	);
		
	dictionary:= {};
	dictionary["FIRST"]:= firstName;
	dictionary["LAST"]:= lastName;
	dictionary["PNR"]:= personalNumber;
	dictionary["COUNTRY"]:= "RS";
	dictionary["ORGNAME"]:= onBoardingData.GeneralCompanyInformation.ShortName;
	dictionary["ORGNR"]:= onBoardingData.GeneralCompanyInformation.OrganizationNumber;
	dictionary["ORGCITY"]:= onBoardingData.GeneralCompanyInformation.CompanyCity;
	dictionary["ORGCOUNTRY"]:= "RS";
	dictionary["ORGADDR"]:= onBoardingData.GeneralCompanyInformation.CompanyAddress;
	dictionary["ORGADDR2"]:= " ";
	dictionary["ORGBANKNUM"]:= onBoardingData.GeneralCompanyInformation.BankAccountNumber;
	dictionary["ORGACTIVITYNUM"]:= onBoardingData.GeneralCompanyInformation.ActivityNumber;
	dictionary["ORGACTIVITY"]:= onBoardingData.GeneralCompanyInformation.ActivityNumber;
	dictionary["ORGTAXNUM"]:= onBoardingData.GeneralCompanyInformation.TaxNumber;
	dictionary["ORGDEPT"]:= "Management";
	dictionary["ORGROLE"]:= "Manager";
	dictionary["IPSONLY"]:= onBoardingData.BusinessData.IPSOnly ? "True" : "False";
	
	PropertiesVector := [FOREACH prop IN dictionary: {name: prop.Key, value: prop.Value}];
	Global.ApplyForAgentLegalId(SessionUser, Password, PropertiesVector);
	
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	generalInfo.CanEdit := false;
	Waher.Persistence.Database.Update(generalInfo);
		
	return(1);
);

SendEmailToVaulter(onBoardingData):= (	
	MailBody := Create(System.Text.StringBuilder);
	MailBody.Append("Hello,");
	MailBody.Append("<br />");
	MailBody.Append("<br />A user <strong>{{user}}</strong> has finished and submit onboarding data.");
	MailBody.Append("<br />Organization short name: <strong>{{organizationShortName}}</strong>");
	MailBody.Append("<br />Organization number: <strong>{{organizationNumber}}</strong>");
	MailBody.Append("<br />Organization tax number: <strong>{{organizationTaxNumber}}</strong>");
	MailBody.Append("<br />");
	MailBody.Append("<br />Please review this request.");
	MailBody.Append("<br />");
	MailBody.Append("<br />Best regards");
	MailBody.Append("<br />Vaulter");
	
	MailBody := Replace(MailBody, "{{user}}", SessionUser.username);
	MailBody := Replace(MailBody, "{{organizationShortName}}", onBoardingData.GeneralCompanyInformation.ShortName);
	MailBody := Replace(MailBody, "{{organizationNumber}}", onBoardingData.GeneralCompanyInformation.OrganizationNumber);
	MailBody := Replace(MailBody, "{{organizationTaxNumber}}", onBoardingData.GeneralCompanyInformation.TaxNumber);
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	mailRecipients := GetSetting("POWRS.PaymentLink.OnBoardingSubmitMailList","");
	
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailRecipients, "Powrs Vaulter OnBoarding", MailBody, null, null);
				
	destroy(MailBody);
	destroy(uploadedDocuments);
	return(1);
);

SendEmailToUser():= (	
	MailBody := Create(System.Text.StringBuilder);
	MailBody.Append("Zdravo {{user}},");
	MailBody.Append("<br />");
	MailBody.Append("<br />Vaša prijava na Vaulter sistem je evidentirana.");
	MailBody.Append("<br />");
	MailBody.Append("<br />Dokumentacija koju ste dodali na naš sistem potrebno je da bude proverena od strane platne institucije, nakon čega će Vas kontaktirati Vaulter tim. Proces verifikacije traje do 5 radnih dana.");
	MailBody.Append("<br />Za sva pitanja možete nas kontaktirati na email adresu queries@vaulter.se ili pozivom na broj 0800 40 40 44.");
	MailBody.Append("<br />");
	MailBody.Append("<br />Srdačan pozdrav,");
	MailBody.Append("<br />Vaulter");
	
	MailBody := Replace(MailBody, "{{user}}", SessionUser.username);
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	mailRecipient := Select EMail from BrokerAccounts where UserName = SessionUser.username;
	
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailRecipient, "Powrs Vaulter OnBoarding", MailBody, null, null);
				
	destroy(MailBody);
	destroy(uploadedDocuments);
	return(1);
);

SetOrganizationClientType(onBoardingData) := (
	organizationClientType := Select top 1 * from POWRS.PaymentLink.ClientType.Models.OrganizationClientType where OrganizationName = onBoardingData.GeneralCompanyInformation.ShortName;
	brokerAccClientType := Select top 1 * from POWRS.PaymentLink.ClientType.Models.BrokerAccountOnboaradingClientTypeTMP where UserName = SessionUser.username;
	
	if(organizationClientType = null)then
	(
		organizationClientType := Create(POWRS.PaymentLink.ClientType.Models.OrganizationClientType);
		organizationClientType.OrganizationName := onBoardingData.GeneralCompanyInformation.ShortName;
		organizationClientType.OrgClientType := brokerAccClientType != null ? brokerAccClientType.OrgClientType : POWRS.PaymentLink.ClientType.Enums.ClientType.Small;
		
		Waher.Persistence.Database.Insert(organizationClientType);
	);

	if(brokerAccClientType != null) then
	(
		Waher.Persistence.Database.Delete(brokerAccClientType);
	);
);

try
(
	allCompaniesRootPath := GetSetting("POWRS.PaymentLink.OnBoardingAllCompaniesRootPath","");
	if(System.String.IsNullOrWhiteSpace(allCompaniesRootPath)) then (
		BadRequest("No setting: OnBoardingAllCompaniesRootPath");
	);
	
	onBoardingData:= POWRS.PaymentLink.Onboarding.Onboarding.GetOnboardingData(SessionUser.username);
	if(!onBoardingData.GeneralCompanyInformation.CanEdit)then(
		Error("Forbidden for submit");
	);
	if(!onBoardingData.CanSubmit)then(
		GetPreciseErrors(onBoardingData);
	);
	
    currentMethod := "ApplyForLeglalID";
	ApplyForLeglalID(onBoardingData);
	
	try
	(
		currentMethod := "SendEmailToVaulter";
		SendEmailToVaulter(onBoardingData);
	)
	catch
	(
		Log.Error("Unable to send email to Powrs onboarding: " + Exception.Message + ", \ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
	);
	try
	(
		currentMethod := "SendEmailToUser";
	)
	catch
	(
		Log.Error("Unable to send email to user: " + Exception.Message + ", \ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
	);
	try
	(
		currentMethod := "UpdateClientType";
		SetOrganizationClientType(onBoardingData);
	)
	catch
	(
		Log.Error("Unable to set org client type: " + Exception.Message + ", \ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
	);
	
	Log.Informational("Succeffully submited onboarding for user: " + SessionUser.username, logObject, logActor, logEventID, null);
	{
		success: true
	}
)
catch
(
	Log.Error("Unable to submit onboarding: " + Exception.Message + ", \ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		BadRequest(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);