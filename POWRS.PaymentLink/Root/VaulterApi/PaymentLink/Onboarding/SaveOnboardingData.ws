SessionUser:= Global.ValidateAgentApiToken(false, false);

if(Posted == null) then BadRequest("Data could not be null");
if(!exists(Posted.GeneralCompanyInformation) or Posted.GeneralCompanyInformation == null) then BadRequest("GeneralCompanyInformation could not be null");
if(!exists(Posted.CompanyStructure) or Posted.CompanyStructure == null) then BadRequest("CompanyStructure could not be null");
if(!exists(Posted.BussinesData) or Posted.BussinesData == null) then BadRequest("BussinesData could not be null");

logObjectID := SessionUser.username;
logEventID := "SaveOnboardingData.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

errors:= Create(System.Collections.Generic.List, System.String);
currentMethod:= "";

ValidatePostedData(Posted) := (	
	if(!exists(Posted.GeneralCompanyInformation.FullName) or
		System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.FullName))then
	(
		errors.Add("GeneralCompanyInformation.FullName");
	);
	if(!exists(Posted.GeneralCompanyInformation.ShortName) or
		System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.ShortName))then
	(
		errors.Add("GeneralCompanyInformation.ShortName");
	);
	if(!exists(Posted.GeneralCompanyInformation.OrganizationNumber) or
		System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.OrganizationNumber))then
	(
		errors.Add("GeneralCompanyInformation.OrganizationNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.CompanyAddress))then(
		errors.Add("GeneralCompanyInformation.CompanyAddress");
	);		
	if(!exists(Posted.GeneralCompanyInformation.CompanyCity))then(
		errors.Add("GeneralCompanyInformation.CompanyCity");
	);	
	if(!exists(Posted.GeneralCompanyInformation.TaxNumber))then(
		errors.Add("GeneralCompanyInformation.TaxNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.ActivityNumber))then(
		errors.Add("GeneralCompanyInformation.ActivityNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.OtherCompanyActivities))then(
		errors.Add("GeneralCompanyInformation.OtherCompanyActivities");
	);	
	if(!exists(Posted.GeneralCompanyInformation.StampUsage))then(
		errors.Add("GeneralCompanyInformation.StampUsage");
	);	
	if(!exists(Posted.GeneralCompanyInformation.BankName))then(
		errors.Add("GeneralCompanyInformation.BankName");
	);	
	if(!exists(Posted.GeneralCompanyInformation.BankAccountNumber))then(
		errors.Add("GeneralCompanyInformation.BankAccountNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.TaxLiability))then(
		errors.Add("GeneralCompanyInformation.TaxLiability");
	);	
	if(!exists(Posted.GeneralCompanyInformation.CompanyWebsite))then(
		errors.Add("GeneralCompanyInformation.CompanyWebsite");
	);	
	if(!exists(Posted.GeneralCompanyInformation.CompanyWebshop))then(
		errors.Add("GeneralCompanyInformation.CompanyWebshop");
	);	
	if(!exists(Posted.GeneralCompanyInformation.LegalRepresentatives))then(
		errors.Add("GeneralCompanyInformation.LegalRepresentatives");
	);
	
	if(Posted.GeneralCompanyInformation.LegalRepresentatives != null and Posted.GeneralCompanyInformation.LegalRepresentatives.Length > 0) then
	(
		itemIndex := 0;
		foreach item in Posted.GeneralCompanyInformation.LegalRepresentatives do
		(
			IsPoliticallyExposedPerson := false;
			
			if(!exists(item.FullName) or
				System.String.IsNullOrWhiteSpace(item.FullName))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".FullName");
			);
			if(!exists(item.DateOfBirth) or
				(!System.String.IsNullOrWhiteSpace(item.DateOfBirth) and item.DateOfBirth not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DateOfBirth");
			);
			if(!exists(item.IsPoliticallyExposedPerson))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IsPoliticallyExposedPerson");
			)else if(item.IsPoliticallyExposedPerson != null) then (
				IsPoliticallyExposedPerson := item.IsPoliticallyExposedPerson;
			);
			if(!exists(item.StatementOfOfficialDocument))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".StatementOfOfficialDocument");
			)else if (IsPoliticallyExposedPerson) then(
				if(System.String.IsNullOrWhiteSpace(item.StatementOfOfficialDocument))then (
					errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".StatementOfOfficialDocument");
				);
			);
			if(!exists(item.IdCard))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IdCard");
			);
			if(!exists(item.DocumentType))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DocumentType");
			);
			if(!exists(item.PlaceOfIssue))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".PlaceOfIssue");
			);
			if(!exists(item.DateOfIssue) or 
				(!System.String.IsNullOrWhiteSpace(item.DateOfIssue) and item.DateOfIssue not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DateOfIssue");
			);
			if(!exists(item.DocumentNumber))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DocumentNumber");
			);
			
			itemIndex++;
		);
	);
	
	
	if(!exists(Posted.CompanyStructure.CountriesOfBusiness))then(
		errors.Add("CompanyStructure.CountriesOfBusiness");
	);	
	if(!exists(Posted.CompanyStructure.PercentageOfForeignUsers))then(
		errors.Add("CompanyStructure.PercentageOfForeignUsers");
	);	
	if(!exists(Posted.CompanyStructure.OffShoreFoundationInOwnerStructure))then(
		errors.Add("CompanyStructure.OffShoreFoundationInOwnerStructure");
	);	
	if(!exists(Posted.CompanyStructure.OwnerStructure))then(
		errors.Add("CompanyStructure.OwnerStructure");
	);	
	if(!exists(Posted.CompanyStructure.Owners))then(
		errors.Add("CompanyStructure.Owners");
	);
	
	if(Posted.CompanyStructure.Owners != null and Posted.CompanyStructure.Owners.Length > 0) then
	(
		itemIndex := 0;
		foreach item in Posted.CompanyStructure.Owners do
		(
			if(!exists(item.FullName))then
			(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".FullName");
			);
			if(!exists(item.PersonalNumber))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".PersonalNumber");
			);
			if(!exists(item.PlaceOfBirth))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".PlaceOfBirth");
			);
			if(!exists(item.OfficialOfRepublicOfSerbia))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".OfficialOfRepublicOfSerbia");
			);
			if(!exists(item.DocumentType))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DocumentType");
			);
			if(!exists(item.DocumentNumber))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DocumentNumber");
			);
			if(!exists(item.IssuerName))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IssuerName");
			);
			if(!exists(item.Citizenship))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".Citizenship");
			);
			if(!exists(item.OwningPercentage))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".OwningPercentage");
			);
			if(!exists(item.Role))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".Role");
			);
			if(!exists(item.DateOfBirth))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DateOfBirth");
			);
			if(!exists(item.IssueDate))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IssueDate");
			);
			itemIndex++;
		);
	);
	
	if(!exists(Posted.BussinesData.RetailersNumber))then(
		errors.Add("BussinesData.RetailersNumber");
	);
	if(!exists(Posted.BussinesData.ExpectedMonthlyTurnover))then(
		errors.Add("BussinesData.ExpectedMonthlyTurnover");
	);
	if(!exists(Posted.BussinesData.ExpectedYearlyTurnover))then(
		errors.Add("BussinesData.ExpectedYearlyTurnover");
	);
	if(!exists(Posted.BussinesData.ThreeMonthAccountTurnover))then(
		errors.Add("BussinesData.ThreeMonthAccountTurnover");
	);
	if(!exists(Posted.BussinesData.CardPaymentPercentage))then(
		errors.Add("BussinesData.CardPaymentPercentage");
	);
	if(!exists(Posted.BussinesData.AverageTransactionAmount))then(
		errors.Add("BussinesData.AverageTransactionAmount");
	);
	if(!exists(Posted.BussinesData.AverageDailyTurnover))then(
		errors.Add("BussinesData.AverageDailyTurnover");
	);
	if(!exists(Posted.BussinesData.CheapestProductAmount))then(
		errors.Add("BussinesData.CheapestProductAmount");
	);
	if(!exists(Posted.BussinesData.BussinesModel))then(
		errors.Add("BussinesData.BussinesModel");
	);
	if(!exists(Posted.BussinesData.SellingGoodsWithDelayedDelivery))then(
		errors.Add("BussinesData.SellingGoodsWithDelayedDelivery");
	);
	if(!exists(Posted.BussinesData.PeriodFromPaymentToDeliveryInDays))then(
		errors.Add("BussinesData.PeriodFromPaymentToDeliveryInDays");
	);
	if(!exists(Posted.BussinesData.ComplaintsPerMonth))then(
		errors.Add("BussinesData.ComplaintsPerMonth");
	);
	if(!exists(Posted.BussinesData.ComplaintsPerYear))then(
		errors.Add("BussinesData.ComplaintsPerYear");
	);
	if(!exists(Posted.BussinesData.MostExpensiveProductAmount))then(
		errors.Add("BussinesData.MostExpensiveProductAmount");
	);
		
	if(errors.Count > 0)then
	(
		Error(errors);
		return (0);
	)else
	(
		return (1); 
	);
);

SaveGeneralCompanyInfo(GeneralCompanyInfo, UserName):= 
(	
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = UserName;
	recordExists:= generalInfo != null;

	if(generalInfo == null) then
	(
		companyInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where OrganizationNumber = GeneralCompanyInfo.OrganizationNumber;
		if(companyInfo != null) then
		(
			Error("GeneralCompanyInfo: Another user has already started the onboarding for this company");
		);
		generalInfo:= Create(POWRS.PaymentLink.Onboarding.GeneralCompanyInformation);
	)
	else if(generalInfo.OrganizationNumber != GeneralCompanyInfo.OrganizationNumber) then
	(
		Error("GeneralCompanyInfo: you can't change organization number");
	);

	generalInfo.UserName := UserName;
	generalInfo.FullName := GeneralCompanyInfo.FullName;
	generalInfo.ShortName := GeneralCompanyInfo.ShortName;
	generalInfo.CompanyAddress := GeneralCompanyInfo.CompanyAddress;
	generalInfo.CompanyCity := GeneralCompanyInfo.CompanyCity;
	generalInfo.OrganizationNumber := GeneralCompanyInfo.OrganizationNumber;
	generalInfo.TaxNumber := GeneralCompanyInfo.TaxNumber;
	generalInfo.ActivityNumber := GeneralCompanyInfo.ActivityNumber;
	generalInfo.OtherCompanyActivities := GeneralCompanyInfo.OtherCompanyActivities;
	generalInfo.StampUsage := GeneralCompanyInfo.StampUsage;
	generalInfo.BankName := GeneralCompanyInfo.BankName;
	generalInfo.BankAccountNumber := GeneralCompanyInfo.BankAccountNumber;
	generalInfo.TaxLiability := GeneralCompanyInfo.TaxLiability;
	generalInfo.OnboardingPurpose := POWRS.PaymentLink.Onboarding.Enums.OnboardingPurpose.Other;        
	generalInfo.PlatformUsage := POWRS.PaymentLink.Onboarding.Enums.PlatformUsage.UsingVaulterPaylinkService;
	generalInfo.CompanyWebsite := GeneralCompanyInfo.CompanyWebsite;
	generalInfo.CompanyWebshop := GeneralCompanyInfo.CompanyWebshop;

	legalRepresentatives:= Create(System.Collections.Generic.List,POWRS.PaymentLink.Onboarding.LegalRepresentative);

	if(GeneralCompanyInfo.LegalRepresentatives != null and GeneralCompanyInfo.LegalRepresentatives.Length > 0) then
	(
		foreach item in GeneralCompanyInfo.LegalRepresentatives do
		(			
			representative:= Create(POWRS.PaymentLink.Onboarding.LegalRepresentative);

			if(!System.String.IsNullOrWhiteSpace(item.DateOfIssue)) then 
			(
				representative.DateOfIssue:= System.DateTime.ParseExact(item.DateOfIssue, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture)
			);	 
			if(!System.String.IsNullOrWhiteSpace(item.DateOfBirth)) then 
			(
				representative.DateOfBirth:= System.DateTime.ParseExact(item.DateOfBirth, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture)
			);

			representative.FullName:= item.FullName;
			representative.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.None;
			representative.DocumentNumber:= item.DocumentNumber;
			representative.PlaceOfIssue:= item.PlaceOfIssue;
			representative.IsPoliticallyExposedPerson:= item.IsPoliticallyExposedPerson;
			representative.StatementOfOfficialDocument:= item.StatementOfOfficialDocument;
			representative.IdCard:= item.IdCard;

			legalRepresentatives.Add(representative);
		);
	);	  

	generalInfo.LegalRepresentatives:= legalRepresentatives.ToArray();

	if(recordExists) then 
	(
		Waher.Persistence.Database.Update(generalInfo);
	)
	else 
	(
		Waher.Persistence.Database.Insert(generalInfo);
	);

	Return(0);
);

try
(
	currentMethod := "ValidatePostedData"; 
	methodResponse := ValidatePostedData(Posted);
	Log.Informational("Finised method ValidatePostedData. \nErrors.cnt: " + Str(errors.Count) + "\nmethodResponse: " + Str(methodResponse), logObjectID, logActor, logEventID, null);
	
	currentMethod := "SaveGeneralCompanyInfo"; 
	methodResponse:= SaveGeneralCompanyInfo(Posted.GeneralCompanyInformation, SessionUser.username);
	Log.Informational("Finised method SaveGeneralCompanyInfo. \nmethodResponse: " + Str(methodResponse), logObjectID, logActor, logEventID, null);
	
	Log.Informational("Succeffully saved OnBoarding data.", logObjectID, logActor, logEventID, null);
	{
		success: true
	}
)
catch
(
	Log.Error("Unable to save onboarding data: " + Exception.Message + "\ncurrentMethod: " + currentMethod, logObjectID, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		BadRequest(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);