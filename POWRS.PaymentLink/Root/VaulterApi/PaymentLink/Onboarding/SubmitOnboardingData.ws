SessionUser:= Global.ValidateAgentApiToken(false, false);

logObjectID := SessionUser.username;
logEventID := "SubmitOnboardingData.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

errors:= Create(System.Collections.Generic.List, System.String);

ValidateSavedData(onBoardingData):=(
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
	if(!onBoardingData.LegalDocuments.IsCompleted())then
	(
		errors.Add("LegalDocuments");
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
	accountRole.ParentOrgName:= "Powrs";
	Waher.Persistence.Database.Update(accountRole);

	Password := 
		select top 1 Password 
		from BrokerAccounts 
		where UserName = SessionUser.username;
		
	firstName := "";
	lastName := "";
		
	fullNameArray := Split(onBoardingData.CompanyStructure.Owners[0].FullName, " ");
	if(fullNameArray.Length == 1)then
	(
		firstName := onBoardingData.CompanyStructure.Owners[0].FullName;
	)
	else 
	(
		firstName := Str(fullNameArray[0]);
		FOR i := 1 TO fullNameArray.Length - 1 STEP 1 DO
		(
			lastName += fullNameArray[i] + ( i != fullNameArray.Length - 1 ? " " : "");
		);
	);
		
	dictionary:= {};
	dictionary["FIRST"]:= firstName;
	dictionary["LAST"]:= lastName;
	dictionary["PNR"]:= onBoardingData.CompanyStructure.Owners[0].PersonalNumber;
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
	dictionary["IPSONLY"]:= onBoardingData.LegalDocuments.PromissoryNote == "" ? "True" : "False";
	
	PropertiesVector := [FOREACH prop IN dictionary: {name: prop.Key, value: prop.Value}];
	Global.ApplyForAgentLegalId(SessionUser, Password, PropertiesVector);
	
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	generalInfo.CanEdit := false;
	Waher.Persistence.Database.Update(generalInfo);
		
	return(1);
);

SendEmail(onBoardingData):= (	
	MailBody := Create(System.Text.StringBuilder);
	MailBody.Append("Hello,");
	MailBody.Append("<br />");
	MailBody.Append("<br />A user <strong>{{user}}</strong> has finished and submit onboarding data.");
	MailBody.Append("<br />Organization short name: <strong>{{organizationShortName}}</strong>");
	MailBody.Append("<br />Organization number: <strong>{{organizationNumber}}</strong>");
	MailBody.Append("<br />Organization tax number: <strong>{{organizationTaxNumber}}</strong>");
	MailBody.Append("<br />Uploaded documents:");
	MailBody.Append("<br />{{uploadedDocuments}}");
	MailBody.Append("<br />");
	MailBody.Append("<br />Please review this request.");
	MailBody.Append("<br />");
	MailBody.Append("<br />Best regards");
	MailBody.Append("<br />Vaulter");
	
	MailBody := Replace(MailBody, "{{user}}", SessionUser.username);
	MailBody := Replace(MailBody, "{{organizationShortName}}", onBoardingData.GeneralCompanyInformation.ShortName);
	MailBody := Replace(MailBody, "{{organizationNumber}}", onBoardingData.GeneralCompanyInformation.OrganizationNumber);
	MailBody := Replace(MailBody, "{{organizationTaxNumber}}", onBoardingData.GeneralCompanyInformation.TaxNumber);
	
    neuronDomain:= "https://" + Gateway.Domain;
	companyLink := neuronDomain + "/VaulterApi/PaymentLink/Onboarding/UploadedFiles/" + onBoardingData.GeneralCompanyInformation.ShortName + "/";
	uploadedDocuments := Create(System.Text.StringBuilder);
	foreach (item in onBoardingData.GeneralCompanyInformation.LegalRepresentatives) do(
		uploadedDocuments.Append("<br /><a href=\"" + companyLink + item.IdCard +"\">" + item.IdCard + "</a>");
		uploadedDocuments.Append("<br /><a href=\"" + companyLink + item.StatementOfOfficialDocument +"\">" + item.StatementOfOfficialDocument + "</a>");
	);
	foreach (item in onBoardingData.CompanyStructure.Owners) do(
		uploadedDocuments.Append("<br /><a href=\"" + companyLink + item.IdCard +"\">" + item.IdCard + "</a>");
		uploadedDocuments.Append("<br /><a href=\"" + companyLink + item.StatementOfOfficialDocument +"\">" + item.StatementOfOfficialDocument + "</a>");
	);
	
	uploadedDocuments.Append("<br /><a href=\"" + companyLink + onBoardingData.LegalDocuments.BusinessCooperationRequest +"\">" + onBoardingData.LegalDocuments.BusinessCooperationRequest + "</a>");
	uploadedDocuments.Append("<br /><a href=\"" + companyLink + onBoardingData.LegalDocuments.ContractWithEMI +"\">" + onBoardingData.LegalDocuments.ContractWithEMI + "</a>");
	uploadedDocuments.Append("<br /><a href=\"" + companyLink + onBoardingData.LegalDocuments.ContractWithVaulter +"\">" + onBoardingData.LegalDocuments.ContractWithVaulter + "</a>");
	if(onBoardingData.LegalDocuments.PromissoryNote != "")then
	(
		uploadedDocuments.Append("<br /><a href=\"" + companyLink + onBoardingData.LegalDocuments.PromissoryNote +"\">" + onBoardingData.LegalDocuments.PromissoryNote + "</a>");
	);
	
	MailBody := Replace(MailBody, "{{uploadedDocuments}}", uploadedDocuments.ToString());
	
	
	ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
	Config := ConfigClass.Instance;
	mailRecipients := GetSetting("POWRS.PaymentLink.OnBoardingSubmitMailList","");
	
	POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, mailRecipients, "Powrs Vaulter OnBoarding", MailBody, null, null);
				
	destroy(MailBody);
	destroy(uploadedDocuments);
	return(1);
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
		ValidateSavedData(onBoardingData);
	)else(
        Error("Onboarding is not allowed to edit or submit content.");
	);
	
	ApplyForLeglalID(onBoardingData);
	SendEmail(onBoardingData);
	
	Log.Informational("Succeffully submited onboarding for user: " + SessionUser.username, logObjectID, logActor, logEventID, null);
	{
		success: true
	}
)
catch
(
	Log.Error("Unable to submit onboarding: " + Exception.Message, logObjectID, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		BadRequest(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);