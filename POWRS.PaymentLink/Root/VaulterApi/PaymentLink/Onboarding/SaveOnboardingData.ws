SessionUser:= Global.ValidateAgentApiToken(false, false);

if(Posted == null) then BadRequest("Data could not be null");
if(!exists(Posted.GeneralCompanyInformation) or Posted.GeneralCompanyInformation == null) then BadRequest("GeneralCompanyInfo could not be null");
if(!exists(Posted.EconomicData) or Posted.EconomicData == null) then BadRequest("EconomicData could not be null");

SaveGeneralCompanyInfo(GeneralCompanyInfo, UserName):= 
(
   if(!exists(GeneralCompanyInfo.FullName) or 
	  !exists(GeneralCompanyInfo.ShortName) or
	  !exists(GeneralCompanyInfo.CompanyAddress) or
	  !exists(GeneralCompanyInfo.CompanyCity) or
	  !exists(GeneralCompanyInfo.OrganizationNumber) or
	  !exists(GeneralCompanyInfo.TaxNumber) or
	  !exists(GeneralCompanyInfo.ActivityNumber) or
	  !exists(GeneralCompanyInfo.OtherCompanyActivities) or
	  !exists(GeneralCompanyInfo.BankName) or
	  !exists(GeneralCompanyInfo.BankAccountNumber) or
	  !exists(GeneralCompanyInfo.StampUsage) or
	  !exists(GeneralCompanyInfo.TaxLiability) or
	  !exists(GeneralCompanyInfo.CompanyWebsite) or
	  !exists(GeneralCompanyInfo.CompanyWebshop) or
	  !exists(GeneralCompanyInfo.LegalRepresentatives)) then
	  (
		BadRequest("Missing fields");
	  );

	  generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = UserName;
	  recordExists:= generalInfo != null;

	  if(generalInfo == null) then 
	  (
		generalInfo:= Create(POWRS.PaymentLink.Onboarding.GeneralCompanyInformation);
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
	  generalInfo.BankName := GeneralCompanyInfo.BankName;
	  generalInfo.BankAccountNumber := GeneralCompanyInfo.BankAccountNumber;
	  generalInfo.StampUsage := GeneralCompanyInfo.StampUsage;
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
			  if(!exists(item.FullName) or
				!exists(item.DateOfBirth) or
				!exists(item.DocumentType) or
				!exists(item.PlaceOfIssue) or
				!exists(item.DateOfIssue) or
				!exists(item.DocumentNumber)) then
				(
					BadRequest("Missing fields for legal representative");
				);
			
			representative:= Create(POWRS.PaymentLink.Onboarding.LegalRepresentative);

			if(!System.String.IsNullOrEmpty(item.DateOfIssue) and item.DateOfIssue like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$") then 
			(
				representative.DateOfIssue:= System.DateTime.ParseExact(item.DateOfIssue, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture)
			);	 
			if(!System.String.IsNullOrEmpty(item.DateOfBirth) and item.DateOfBirth like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$") then 
			(
				representative.DateOfBirth:= System.DateTime.ParseExact(item.DateOfBirth, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture)
			);

			representative.FullName:= item.FullName;
			representative.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.None;
			representative.DocumentNumber:= item.DocumentNumber;
			representative.PlaceOfIssue:= item.PlaceOfIssue;

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

SaveBussinesData(BussinesData, UserName):= 
(
	if(!exists(BussinesData.RetailersNumber) or
		!exists(BussinesData.ExpectedMonthlyTurnover) or
		!exists(BussinesData.ExpectedYearlyTurnover) or
		!exists(BussinesData.ThreeMonthAccountTurnover) or
		!exists(BussinesData.CardPaymentPercentage) or
		!exists(BussinesData.AverageTransactionAmount) or
		!exists(BussinesData.AverageDailyTurnover) or
		!exists(BussinesData.CheapestProductAmount) or
		!exists(BussinesData.BussinesModel) or
		!exists(BussinesData.SellingGoodsWithDelayedDelivery) or
		!exists(BussinesData.PeriodFromPaymentToDeliveryInDays) or
		!exists(BussinesData.ComplaintsPerMonth) or
		!exists(BussinesData.ComplaintsPerYear) or
		!exists(BussinesData.MostExpensiveProductAmount)) then 
		(
			BadRequest("Missing data");
		);

		bussinesData:= select top 1 * from POWRS.PaymentLink.Onboarding.BussinesData where UserName = UserName;
	    recordExists:= bussinesData != null;

		if(bussinesData == null) then 
		(
			bussinesData:= Create(POWRS.PaymentLink.Onboarding.BussinesData, UserName);
		);

		bussinesData.UserName:= UserName;
		bussinesData.RetailersNumber:= BussinesData.RetailersNumber;
		bussinesData.ExpectedMonthlyTurnover:= BussinesData.ExpectedMonthlyTurnover;
		bussinesData.ExpectedYearlyTurnover:= BussinesData.ExpectedYearlyTurnover;
		bussinesData.ThreeMonthAccountTurnover:= BussinesData.ThreeMonthAccountTurnover;
		bussinesData.CardPaymentPercentage:= Int(BussinesData.CardPaymentPercentage;
		bussinesData.AverageDailyTurnover:= BussinesData.AverageDailyTurnover;
		bussinesData.CheapestProductAmount:= BussinesData.CheapestProductAmount;
		bussinesData.MostExpensiveProductAmount:= BussinesData.MostExpensiveProductAmount;
		bussinesData.BussinesModel:= BussinesData.BussinesModel;
		bussinesData.SellingGoodsWithDelayedDelivery:= BussinesData.SellingGoodsWithDelayedDelivery;
		bussinesData.PeriodFromPaymentToDeliveryInDays:= BussinesData.PeriodFromPaymentToDeliveryInDays;
		bussinesData.ComplaintsPerMonth:= BussinesData.ComplaintsPerMonth;
		bussinesData.ComplaintsPerYear:= BussinesData.ComplaintsPerYear;

		if(recordExists) then 
		(
			Waher.Persistence.Database.Update(economicData);
		)
		else 
		(
			Waher.Persistence.Database.Insert(economicData);
		);

	  Return(0);
);

SaveCompanyStructure(CompanyStructure, UserName):=
(
	if(!exists(CompanyStructure.CountriesOfBusiness) or 
	!exists(CompanyStructure.PercentageOfForeignUsers) or 
	!exists(CompanyStructure.OffShoreFoundationInOwnerStructure) or 
	!exists(CompanyStructure.OwnerStructure) or 
	!exists(CompanyStructure.Owners)) then
	(
		BadRequest("Fields are missing from request");
	);

	structure:= select top 1 * from POWRS.PaymentLink.Onboarding.Structure.CompanyStructure where UserName = UserName;
	alreadyExists:= structure != null;

	if(structure == null) then 
	(
		structure:= Create(POWRS.PaymentLink.Onboarding.Structure.CompanyStructure, UserName);
	);

	countriesOfBussines:= Create(System.Collections.Generic.List,System.String);
	owners:= Create(System.Collections.Generic.List, POWRS.PaymentLink.Onboarding.Structure.Owner);

	structure.PercentageOfForeignUsers:= CompanyStructure.PercentageOfForeignUsers;
	structure.OffShoreFoundationInOwnerStructure:= CompanyStructure.OffShoreFoundationInOwnerStructure;
	structure.OwnerStructure:= CompanyStructure.OwnerStructure;

	if(CompanyStructure.CountriesOfBusiness != null and CompanyStructure.CountriesOfBusiness.Length > 0) then 
	(
		foreach(country in CompanyStructure.CountriesOfBusiness) do 
		(
			countriesOfBussines.Add(country);
		);
	);

	if(CompanyStructure.Owners != null and CompanyStructure.Owners.Length > 0) then 
	(
		foreach(item in CompanyStructure.Owners) do
		(
			owner:= Create(POWRS.PaymentLink.Onboarding.Structure.Owner);
			owner.FullName:= item.FullName;
			owner.PersonalNumber:= item.PersonalNumber;
			owner.PlaceOfBirth:= item.PlaceOfBirth;
			owner.OfficialOfRepublicOfSerbia:= item.OfficialOfRepublicOfSerbia;
			owner.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType);
			owner.DocumentNumber:= item.DocumentNumber;
			owner.IssuerName:= item.IssuerName;
			owner.Citizenship:= item.Citizenship;
			owner.OwningPercentage:= item.OwningPercentage;
			owner.Role:= item.Role;

			if(item.DateOfBirth != null and and item.DateOfBirth like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$") then 
			(
				owner.DateOfBirth:= System.DateTime.ParseExact(item.DateOfBirth, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
			);
			if(item.IssueDate != null and and item.IssueDate like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$") then 
			(
				owner.IssueDate:= System.DateTime.ParseExact(item.IssueDate, "dd/MM/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
			);

			owners.Add(owner);
		);

		structure.Owners:= owners;
	);


	if(alreadyExists) then 
	(
		Waher.Persistence.Database.Update(structure);
	)
	else 
	(
		Waher.Persistence.Database.Insert(structure);
	);

	Return(0);

);



SaveGeneralCompanyInfo(Posted.GeneralCompanyInformation, SessionUser.username);
SaveEconomicData(Posted.EconomicData, SessionUser.username);