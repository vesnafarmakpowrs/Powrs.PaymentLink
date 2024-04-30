SessionUser:= Global.ValidateAgentApiToken(false, false);

if(Posted == null) then BadRequest("Data could not be null");
if(!exists(Posted.GeneralCompanyInformation) or Posted.GeneralCompanyInformation == null) then BadRequest("GeneralCompanyInformation could not be null");
if(!exists(Posted.CompanyStructure) or Posted.CompanyStructure == null) then BadRequest("CompanyStructure could not be null");
if(!exists(Posted.BusinessData) or Posted.BusinessData == null) then BadRequest("BusinessData could not be null");

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
	if(!exists(Posted.CompanyStructure.NameOfTheForeignExchangeAndIDNumber))then(
		errors.Add("CompanyStructure.NameOfTheForeignExchangeAndIDNumber");
	);
	if(!exists(Posted.CompanyStructure.OffShoreFoundationInOwnerStructure))then(
		errors.Add("CompanyStructure.OffShoreFoundationInOwnerStructure");
	);
	if(!exists(Posted.CompanyStructure.PercentageOfForeignUsers))then(
		errors.Add("CompanyStructure.PercentageOfForeignUsers");
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
			IsPoliticallyExposedPerson:= false;
			
			if(!exists(item.FullName))then
			(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".FullName");
			);
			if(!exists(item.PersonalNumber))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".PersonalNumber");
			);
			if(!exists(item.DateOfBirth) or 
				(!System.String.IsNullOrWhiteSpace(item.DateOfBirth) and item.DateOfBirth not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"))then
			(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DateOfBirth");
			);
			if(!exists(item.PlaceOfBirth))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".PlaceOfBirth");
			);
			if(!exists(item.AddressAndPlaceOfResidence))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".AddressAndPlaceOfResidence");
			);			
			if(!exists(item.IsPoliticallyExposedPerson))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IsPoliticallyExposedPerson");
			)else if(item.IsPoliticallyExposedPerson != null) then (
				IsPoliticallyExposedPerson := item.IsPoliticallyExposedPerson;
			);
			if(!exists(item.StatementOfOfficialDocument))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".StatementOfOfficialDocument");
			)else if (IsPoliticallyExposedPerson) then(
				if(System.String.IsNullOrWhiteSpace(item.StatementOfOfficialDocument))then (
					errors.Add("CompanyStructure.Owners;" + itemIndex + ".StatementOfOfficialDocument");
				);
			);
			if(!exists(item.OwningPercentage))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".OwningPercentage");
			);
			if(!exists(item.Role))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".Role");
			);
			if(!exists(item.DocumentType))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DocumentType");
			);
			if(!exists(item.DocumentNumber))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DocumentNumber");
			);
			if(!exists(item.IssueDate) or 
				(!System.String.IsNullOrWhiteSpace(item.IssueDate) and item.IssueDate not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"))then
			(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IssueDate");
			);
			if(!exists(item.IssuerName))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IssuerName");
			);
			if(!exists(item.DocumentIssuancePlace))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DocumentIssuancePlace");
			);
			if(!exists(item.Citizenship))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".Citizenship");
			);
			if(!exists(item.IdCard))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IdCard");
			);
			
			itemIndex++;
		);
	);
	
	if(!exists(Posted.BusinessData.BusinessModel))then(
		errors.Add("BusinessData.BusinessModel");
	);
	if(!exists(Posted.BusinessData.RetailersNumber))then(
		errors.Add("BusinessData.RetailersNumber");
	);
	if(!exists(Posted.BusinessData.ExpectedMonthlyTurnover))then(
		errors.Add("BusinessData.ExpectedMonthlyTurnover");
	);
	if(!exists(Posted.BusinessData.ExpectedYearlyTurnover))then(
		errors.Add("BusinessData.ExpectedYearlyTurnover");
	);
	if(!exists(Posted.BusinessData.ThreeMonthAccountTurnover))then(
		errors.Add("BusinessData.ThreeMonthAccountTurnover");
	);
	if(!exists(Posted.BusinessData.CardPaymentPercentage))then(
		errors.Add("BusinessData.CardPaymentPercentage");
	);
	if(!exists(Posted.BusinessData.AverageTransactionAmount))then(
		errors.Add("BusinessData.AverageTransactionAmount");
	);
	if(!exists(Posted.BusinessData.AverageDailyTurnover))then(
		errors.Add("BusinessData.AverageDailyTurnover");
	);
	if(!exists(Posted.BusinessData.CheapestProductAmount))then(
		errors.Add("BusinessData.CheapestProductAmount");
	);
	if(!exists(Posted.BusinessData.MostExpensiveProductAmount))then(
		errors.Add("BusinessData.MostExpensiveProductAmount");
	);
	if(!exists(Posted.BusinessData.SellingGoodsWithDelayedDelivery))then(
		errors.Add("BusinessData.SellingGoodsWithDelayedDelivery");
	);
	if(!exists(Posted.BusinessData.PeriodFromPaymentToDeliveryInDays))then(
		errors.Add("BusinessData.PeriodFromPaymentToDeliveryInDays");
	);
	if(!exists(Posted.BusinessData.ComplaintsPerMonth))then(
		errors.Add("BusinessData.ComplaintsPerMonth");
	);
	if(!exists(Posted.BusinessData.ComplaintsPerYear))then(
		errors.Add("BusinessData.ComplaintsPerYear");
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

			representative.FullName:= item.FullName;
			representative.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard;
			representative.DocumentNumber:= item.DocumentNumber;
			representative.PlaceOfIssue:= item.PlaceOfIssue;
			representative.IsPoliticallyExposedPerson:= item.IsPoliticallyExposedPerson;
			representative.StatementOfOfficialDocument:= item.StatementOfOfficialDocument;
			representative.IdCard:= item.IdCard;
			
			if(!System.String.IsNullOrWhiteSpace(item.DateOfIssue)) then 
			(
				representative.DateOfIssue:= System.DateTime.ParseExact(item.DateOfIssue, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture)
			);	 
			if(!System.String.IsNullOrWhiteSpace(item.DateOfBirth)) then 
			(
				representative.DateOfBirth:= System.DateTime.ParseExact(item.DateOfBirth, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture)
			);
			
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

SaveCompanyStructure(CompanyStructure, UserName):=
(
	companyStructure:= select top 1 * from POWRS.PaymentLink.Onboarding.CompanyStructure where UserName = UserName;
	alreadyExists:= companyStructure != null;

	if(companyStructure == null) then 
	(
		companyStructure:= Create(POWRS.PaymentLink.Onboarding.CompanyStructure, UserName);
	);

	countriesOfBusiness:= Create(System.Collections.Generic.List, System.String);
	owners:= Create(System.Collections.Generic.List, POWRS.PaymentLink.Onboarding.Owner);
	
	companyStructure.UserName:= UserName;
	companyStructure.CountriesOfBusinessSetValue(CompanyStructure.CountriesOfBusiness);
	companyStructure.NameOfTheForeignExchangeAndIDNumber:= CompanyStructure.NameOfTheForeignExchangeAndIDNumber;
	companyStructure.PercentageOfForeignUsers:= CompanyStructure.PercentageOfForeignUsers;
	companyStructure.OffShoreFoundationInOwnerStructure:= CompanyStructure.OffShoreFoundationInOwnerStructure;
	companyStructure.OwnerStructure:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.OwnerStructure, CompanyStructure.OwnerStructure) ??? POWRS.PaymentLink.Onboarding.Enums.OwnerStructure.Company;

	if(CompanyStructure.Owners != null and CompanyStructure.Owners.Length > 0) then 
	(
		foreach(item in CompanyStructure.Owners) do
		(
			owner:= Create(POWRS.PaymentLink.Onboarding.Owner);
			
			owner.FullName:= item.FullName;
			owner.PersonalNumber:= item.PersonalNumber;
			owner.PlaceOfBirth:= item.PlaceOfBirth;
			owner.AddressAndPlaceOfResidence:= item.AddressAndPlaceOfResidence;
			owner.IsPoliticallyExposedPerson:= item.IsPoliticallyExposedPerson;
			owner.StatementOfOfficialDocument:= item.StatementOfOfficialDocument;
			owner.OwningPercentage:= item.OwningPercentage;
			owner.Role:= item.Role;
			owner.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard;
			owner.DocumentNumber:= item.DocumentNumber;
			owner.IssuerName:= item.IssuerName;
			owner.DocumentIssuancePlace:= item.DocumentIssuancePlace;
			owner.Citizenship:= item.Citizenship;
			owner.IdCard:= item.IdCard;

			if(!System.String.IsNullOrWhiteSpace(item.DateOfBirth)) then 
			(
				owner.DateOfBirth:= System.DateTime.ParseExact(item.DateOfBirth, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
			);
			if(!System.String.IsNullOrWhiteSpace(item.IssueDate)) then 
			(
				owner.IssueDate:= System.DateTime.ParseExact(item.IssueDate, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
			);

			owners.Add(owner);
		);
	);
	
	companyStructure.Owners:= owners.ToArray();

	if(alreadyExists) then 
	(
		Waher.Persistence.Database.Update(companyStructure);
	)
	else 
	(
		Waher.Persistence.Database.Insert(companyStructure);
	);

	Return(0);
);

SaveBusinessData(BusinessData, UserName):= 
(
	businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = UserName;
	recordExists:= businessData != null;

	if(businessData == null) then 
	(
		businessData:= Create(POWRS.PaymentLink.Onboarding.BusinessData, UserName);
	);

	businessData.UserName:= UserName;
	businessData.BusinessModel:= BusinessData.BusinessModel;
	businessData.RetailersNumber:= BusinessData.RetailersNumber;
	businessData.ExpectedMonthlyTurnover:= BusinessData.ExpectedMonthlyTurnover;
	businessData.ExpectedYearlyTurnover:= BusinessData.ExpectedYearlyTurnover;
	businessData.ThreeMonthAccountTurnover:= BusinessData.ThreeMonthAccountTurnover;
	businessData.CardPaymentPercentage:= Int(BusinessData.CardPaymentPercentage);
	businessData.AverageTransactionAmount:= BusinessData.AverageTransactionAmount;
	businessData.AverageDailyTurnover:= BusinessData.AverageDailyTurnover;
	businessData.CheapestProductAmount:= BusinessData.CheapestProductAmount;
	businessData.MostExpensiveProductAmount:= BusinessData.MostExpensiveProductAmount;
	businessData.SellingGoodsWithDelayedDelivery:= BusinessData.SellingGoodsWithDelayedDelivery;
	businessData.PeriodFromPaymentToDeliveryInDays:= BusinessData.PeriodFromPaymentToDeliveryInDays;
	businessData.ComplaintsPerMonth:= BusinessData.ComplaintsPerMonth;
	businessData.ComplaintsPerYear:= BusinessData.ComplaintsPerYear;

	if(recordExists) then 
	(
		Waher.Persistence.Database.Update(businessData);
	)
	else 
	(
		Waher.Persistence.Database.Insert(businessData);
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
	
	currentMethod := "SaveCompanyStructure"; 
	methodResponse:= SaveCompanyStructure(Posted.CompanyStructure, SessionUser.username);
	Log.Informational("Finised method SaveCompanyStructure. \nmethodResponse: " + Str(methodResponse), logObjectID, logActor, logEventID, null);
	
	currentMethod := "SaveBusinessData"; 
	methodResponse:= SaveBusinessData(Posted.BusinessData, SessionUser.username);
	Log.Informational("Finised method SaveBusinessData. \nmethodResponse: " + Str(methodResponse), logObjectID, logActor, logEventID, null);
	
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