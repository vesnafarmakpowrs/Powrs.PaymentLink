﻿SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "SaveOnboardingData.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

if(Posted == null) then NotAcceptable("Data could not be null");

errors:= Create(System.Collections.Generic.List, System.String);
currentMethod:= "";
fileMaxSizeMB := Dbl(GetSetting("POWRS.PaymentLink.OnBoardingFileMaxSize", "25"));

ValidatePostedData(Posted) := (
	if(!exists(Posted.GeneralCompanyInformation) or Posted.GeneralCompanyInformation == null) then errors.Add("GeneralCompanyInformation could not be null");
	if(!exists(Posted.CompanyStructure) or Posted.CompanyStructure == null) then errors.Add("CompanyStructure could not be null");
	if(!exists(Posted.BusinessData) or Posted.BusinessData == null) then errors.Add("BusinessData could not be null");
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);

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
	)
	else if(Global.RegexValidation(Posted.GeneralCompanyInformation.OrganizationNumber, "OrgNumber", "") == false) then
	(
		errors.Add("GeneralCompanyInformation.OrganizationNumber");
	);
	if(!exists(Posted.GeneralCompanyInformation.CompanyAddress))then(
		errors.Add("GeneralCompanyInformation.CompanyAddress");
	);	
	if(!exists(Posted.GeneralCompanyInformation.StampUsage))then(
		errors.Add("GeneralCompanyInformation.StampUsage");
	);	
	if(!exists(Posted.GeneralCompanyInformation.TaxLiability))then(
		errors.Add("GeneralCompanyInformation.TaxLiability");
	);		
	if(!exists(Posted.GeneralCompanyInformation.CompanyCity))then(
		errors.Add("GeneralCompanyInformation.CompanyCity");
	);	
	if(!exists(Posted.GeneralCompanyInformation.TaxNumber))then(
		errors.Add("GeneralCompanyInformation.TaxNumber");
	)else if (!System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.TaxNumber) and Global.RegexValidation(Posted.GeneralCompanyInformation.TaxNumber, "OrgTaxNumber", "") == false)then(
		errors.Add("GeneralCompanyInformation.TaxNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.ActivityNumber))then(
		errors.Add("GeneralCompanyInformation.ActivityNumber");
	)else if (!System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.ActivityNumber) and Global.RegexValidation(Posted.GeneralCompanyInformation.ActivityNumber, "OrgActivityNumber", "") == false)then(
		errors.Add("GeneralCompanyInformation.ActivityNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.OtherCompanyActivities))then(
		errors.Add("GeneralCompanyInformation.OtherCompanyActivities");
	);
	if(!exists(Posted.GeneralCompanyInformation.BankName))then(
		errors.Add("GeneralCompanyInformation.BankName");
	);	
	if(!exists(Posted.GeneralCompanyInformation.BankAccountNumber))then(
		errors.Add("GeneralCompanyInformation.BankAccountNumber");
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
			isNewUpload := false;
				
			if(!exists(item.FullName))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".FullName");
			);
			if(!exists(item.DateOfBirth) or
				(!System.String.IsNullOrWhiteSpace(item.DateOfBirth) and Global.RegexValidation(item.DateOfBirth, "DateDDMMYYYY", "") == false))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DateOfBirth");
			);
			if(!exists(item.IsPoliticallyExposedPerson))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IsPoliticallyExposedPerson");
			);			
			if(!exists(item.DocumentType))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DocumentType");
			);
			if(!exists(item.PlaceOfIssue))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".PlaceOfIssue");
			);
			if(!exists(item.DateOfIssue) or 
				(!System.String.IsNullOrWhiteSpace(item.DateOfIssue) and Global.RegexValidation(item.DateOfIssue, "DateDDMMYYYY", "") == false))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DateOfIssue");
			);
			if(!exists(item.DocumentNumber))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DocumentNumber");
			);
			if(!exists(item.IssuerName))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IssuerName");
			);
			if(!exists(item.PlaceOfBirth))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".PlaceOfBirth");
			);
			if(!exists(item.AddressOfResidence))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".AddressOfResidence");
			);
			if(!exists(item.CityOfResidence))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".CityOfResidence");
			);
			if(!exists(item.PersonalNumber))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".PersonalNumber");
			)else
			(
				if(!System.String.IsNullOrWhiteSpace(item.PersonalNumber) and Global.RegexValidation(item.PersonalNumber, "PersonalNumber", "RS") == false)then
				(
					errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".PersonalNumber");
				);
			);
			
			itemIndex++;
		);
	);
	
	Int(Posted.CompanyStructure.PercentageOfForeignUsers) ??? errors.Add("CompanyStructure.PercentageOfForeignUsers");
	
	if(!exists(Posted.CompanyStructure.CountriesOfBusiness))then(
		errors.Add("CompanyStructure.CountriesOfBusiness");
	);
	if(!exists(Posted.CompanyStructure.NameOfTheForeignExchangeAndIDNumber))then(
		errors.Add("CompanyStructure.NameOfTheForeignExchangeAndIDNumber");
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
			isNewUpload := false;
			
			Int(item.OwningPercentage) ??? errors.Add("CompanyStructure.Owners;" + itemIndex + ".OwningPercentage");
						
			if(!exists(item.FullName))then
			(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".FullName");
			);
			if(!exists(item.PersonalNumber))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".PersonalNumber");
			)
			else
			(
				if(!System.String.IsNullOrWhiteSpace(item.PersonalNumber) and Global.RegexValidation(item.PersonalNumber, "PersonalNumber", "RS") == false)then
				(
					errors.Add("CompanyStructure.Owners;" + itemIndex + ".PersonalNumber");
				);
			);
			if(!exists(item.DateOfBirth) or 
				(!System.String.IsNullOrWhiteSpace(item.DateOfBirth) and Global.RegexValidation(item.DateOfBirth, "DateDDMMYYYY", "") == false))then
			(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".DateOfBirth");
			);
			if(!exists(item.PlaceOfBirth))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".PlaceOfBirth");
			);
			if(!exists(item.AddressOfResidence))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".AddressOfResidence");
			);
			if(!exists(item.CityOfResidence))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".CityOfResidence");
			);
			if(!exists(item.IsPoliticallyExposedPerson))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IsPoliticallyExposedPerson");
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
				(!System.String.IsNullOrWhiteSpace(item.IssueDate) and Global.RegexValidation(item.IssueDate, "DateDDMMYYYY", "") == false))then
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
			
			itemIndex++;
		);
	);
	
	Int(Posted.BusinessData.RetailersNumber) ??? errors.Add("BusinessData.RetailersNumber");
	Int(Posted.BusinessData.ExpectedMonthlyTurnover) ??? errors.Add("BusinessData.ExpectedMonthlyTurnover");
	Int(Posted.BusinessData.ExpectedYearlyTurnover) ??? errors.Add("BusinessData.ExpectedYearlyTurnover");
	Int(Posted.BusinessData.ThreeMonthAccountTurnover) ??? errors.Add("BusinessData.ThreeMonthAccountTurnover");
	Int(Posted.BusinessData.CardPaymentPercentage) ??? errors.Add("BusinessData.CardPaymentPercentage");
	Int(Posted.BusinessData.AverageTransactionAmount) ??? errors.Add("BusinessData.AverageTransactionAmount");
	Int(Posted.BusinessData.AverageDailyTurnover) ??? errors.Add("BusinessData.AverageDailyTurnover");
	Int(Posted.BusinessData.CheapestProductAmount) ??? errors.Add("BusinessData.CheapestProductAmount");
	Int(Posted.BusinessData.MostExpensiveProductAmount) ??? errors.Add("BusinessData.MostExpensiveProductAmount");
	Int(Posted.BusinessData.PeriodFromPaymentToDeliveryInDays) ??? errors.Add("BusinessData.PeriodFromPaymentToDeliveryInDays");
	Int(Posted.BusinessData.ComplaintsPerMonth) ??? errors.Add("BusinessData.ComplaintsPerMonth");
	Int(Posted.BusinessData.ComplaintsPerYear) ??? errors.Add("BusinessData.ComplaintsPerYear");
	
	if(!exists(Posted.BusinessData.BusinessModel))then(
		errors.Add("BusinessData.BusinessModel");
	);
	if(!exists(Posted.BusinessData.MethodOfDeliveringGoodsToCustomers))then(
		errors.Add("BusinessData.MethodOfDeliveringGoodsToCustomers");
	);
	if(!exists(Posted.BusinessData.SellingGoodsWithDelayedDelivery))then(
		errors.Add("BusinessData.SellingGoodsWithDelayedDelivery");
	);
	if(!exists(Posted.BusinessData.DescriptionOfTheGoodsToBeSoldOnline))then(
		errors.Add("BusinessData.DescriptionOfTheGoodsToBeSoldOnline");
	);
	if(!exists(Posted.BusinessData.EComerceContactFullName))then(
		errors.Add("BusinessData.EComerceContactFullName");
	);
	if(!exists(Posted.BusinessData.EComerceResponsiblePersonPhone))then(
		errors.Add("BusinessData.EComerceResponsiblePersonPhone");
	);
	if(!exists(Posted.BusinessData.EComerceContactEmail))then(
		errors.Add("BusinessData.EComerceContactEmail");
	);
	if(!exists(Posted.BusinessData.IPSOnly))then(
		errors.Add("BusinessData.IPSOnly");
	);
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);
	
	return (1); 
);

SaveGeneralCompanyInfo(GeneralCompanyInfo, UserName):= 
(
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = UserName;
	recordExists:= generalInfo != null;
	newShortName := Trim(GeneralCompanyInfo.ShortName);
	
	if(generalInfo == null) then
	(
		companyInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where OrganizationNumber = GeneralCompanyInfo.OrganizationNumber;
		if(companyInfo != null) then
		(
			Error("GeneralCompanyInfo: Another user has already started the onboarding for this company");
		);
		generalInfo:= Create(POWRS.PaymentLink.Onboarding.GeneralCompanyInformation);
		generalInfo.CanEdit := true;
		generalInfo.Created := Now;		
	)
	else if(!generalInfo.CanEdit)then
	(
		Error("Forbidden to change data");
	)
	else if(generalInfo.OrganizationNumber != GeneralCompanyInfo.OrganizationNumber) then
	(
		Error("GeneralCompanyInfo: you can't change organization number");
	);
	
	generalInfo.Updated := Now;
	generalInfo.UserName := UserName;
	generalInfo.FullName := Trim(GeneralCompanyInfo.FullName);
	generalInfo.ShortName := newShortName;
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
		itemNo := 0;
		foreach item in GeneralCompanyInfo.LegalRepresentatives do
		(
			itemNo++;
			representative:= Create(POWRS.PaymentLink.Onboarding.LegalRepresentative);		

			representative.FullName:= Trim(item.FullName);
			representative.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard;
			representative.DocumentNumber:= item.DocumentNumber;
			representative.PlaceOfIssue:= item.PlaceOfIssue;
			representative.IsPoliticallyExposedPerson:= item.IsPoliticallyExposedPerson;
			representative.IssuerName:= item.IssuerName;
			representative.PlaceOfBirth:= item.PlaceOfBirth;
			representative.AddressOfResidence:= item.AddressOfResidence;
			representative.CityOfResidence:= item.CityOfResidence;
			representative.PersonalNumber:= item.PersonalNumber;
			
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

SaveCompanyStructure(CompanyStructure, UserName, organizationNumber):=
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
		itemNo := 0;
		foreach(item in CompanyStructure.Owners) do
		(
			itemNo++;
			owner:= Create(POWRS.PaymentLink.Onboarding.Owner);
			
			owner.FullName:= Trim(item.FullName);
			owner.PersonalNumber:= item.PersonalNumber;
			owner.PlaceOfBirth:= item.PlaceOfBirth;
			owner.AddressOfResidence:= item.AddressOfResidence;
			owner.CityOfResidence:= item.CityOfResidence;
			owner.IsPoliticallyExposedPerson:= item.IsPoliticallyExposedPerson;
			owner.OwningPercentage:= item.OwningPercentage;
			owner.Role:= item.Role;
			owner.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard;
			owner.DocumentNumber:= item.DocumentNumber;
			owner.IssuerName:= item.IssuerName;
			owner.DocumentIssuancePlace:= item.DocumentIssuancePlace;
			owner.Citizenship:= item.Citizenship;
			
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
	businessData.MethodOfDeliveringGoodsToCustomers:= BusinessData.MethodOfDeliveringGoodsToCustomers;
	businessData.DescriptionOfTheGoodsToBeSoldOnline:= BusinessData.DescriptionOfTheGoodsToBeSoldOnline;
	businessData.EComerceContactFullName:= BusinessData.EComerceContactFullName;
	businessData.EComerceResponsiblePersonPhone:= BusinessData.EComerceResponsiblePersonPhone;
	businessData.EComerceContactEmail:= BusinessData.EComerceContactEmail;
	businessData.IPSOnly:= BusinessData.IPSOnly;

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
	ValidatePostedData(Posted);
	
	currentMethod := "SaveGeneralCompanyInfo"; 
	SaveGeneralCompanyInfo(Posted.GeneralCompanyInformation, SessionUser.username);
	
	currentMethod := "SaveCompanyStructure"; 
	SaveCompanyStructure(Posted.CompanyStructure, SessionUser.username, Posted.GeneralCompanyInformation.OrganizationNumber);
	
	currentMethod := "SaveBusinessData"; 
	SaveBusinessData(Posted.BusinessData, SessionUser.username);
		
	Log.Informational("Succeffully saved OnBoarding data.", logObject, logActor, logEventID, null);
	{
		success: true
	}
)
catch
(
	Log.Error("Unable to save onboarding data: " + Exception.Message + "\ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		NotAcceptable(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);