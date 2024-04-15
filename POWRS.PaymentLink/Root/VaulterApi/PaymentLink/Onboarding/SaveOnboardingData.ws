SessionUser:= Global.ValidateAgentApiToken(false, false);

if(Posted == null) BadRequest("Data could not be null");

if(Posted.GeneralCompanyInfo == null) BadRequest("GeneralCompanyInfo could not be null");
if(Posted.CompanyModel == null) BadRequest("CompanyModel could not be null");
if(Posted.CompanyStructure == null) BadRequest("CompanyStructure could not be null");
if(Posted.EconomicData == null) BadRequest("EconomicData could not be null");

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
	  !exists(GeneralCompanyInfo.OnboardingPurpose) or
	  !exists(GeneralCompanyInfo.PlatformUsage) or
	  !exists(GeneralCompanyInfo.CompanyWebsite) or
	  !exists(GeneralCompanyInfo.CompanyWebshop) or
	  !exists(GeneralCompanyInfo.LegalRepresentatives)) then
	  (
		BadRequest("Missing fields");
	  );

	  generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = UserName;
	  recordExists:= generalInfo != null;

	  generalInfo = generalInfo ?? Create(POWRS.PaymentLink.Onboarding.GeneralCompanyInformation);

	  generalInfo.UserName = UserName;
	  generalInfo.FullName = GeneralCompanyInfo.FullName;
	  generalInfo.ShortName = GeneralCompanyInfo.ShortName;
	  generalInfo.CompanyAddress = GeneralCompanyInfo.CompanyAddress;
	  generalInfo.CompanyCity = GeneralCompanyInfo.CompanyCity;
	  generalInfo.OrganizationNumber = GeneralCompanyInfo.OrganizationNumber;
	  generalInfo.TaxNumber = GeneralCompanyInfo.TaxNumber;
	  generalInfo.ActivityNumber = GeneralCompanyInfo.ActivityNumber;
	  generalInfo.OtherCompanyActivities = GeneralCompanyInfo.OtherCompanyActivities;
	  generalInfo.BankName = GeneralCompanyInfo.BankName;
	  generalInfo.BankAccountNumber = GeneralCompanyInfo.BankAccountNumber;
	  generalInfo.StampUsage = System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.StampUsage, GeneralCompanyInfo.StampUsage) ??? POWRS.PaymentLink.Onboarding.Enums.StampUsage.None;
	  generalInfo.TaxLiability = System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.TaxLiability, GeneralCompanyInfo.TaxLiability) ??? POWRS.PaymentLink.Onboarding.Enums.TaxLiability.None;
	  generalInfo.OnboardingPurpose = POWRS.PaymentLink.Onboarding.Enums.OnboardingPurpose.Other;        
	  generalInfo.PlatformUsage = POWRS.PaymentLink.Onboarding.Enums.PlatformUsage.UsingVaulterPaylinkService;
	  generalInfo.CompanyWebsite = GeneralCompanyInfo.CompanyWebsite;
	  generalInfo.CompanyWebshop = GeneralCompanyInfo.CompanyWebshop;

	  legalRepresentatives:= Create(System.Collections.Generic.List,POWRS.PaymentLink.Onboarding.LegalRepresentative);

	  foreach item in generalInfo.LegalRepresentatives do
	  (
	    representative:= Create(POWRS.PaymentLink.Onboarding.LegalRepresentative);

		representative.FullName:= item.FullName;
		representative.DateOfBirth:= item.DateOfBirth;
		representative.DocumentType:= System.Enum.Parse(POWRS.PaymentLink.Onboarding.Enums.DocumentType, item.DocumentType) ??? POWRS.PaymentLink.Onboarding.Enums.DocumentType.None;
		representative.DocumentNumber:= item.DocumentNumber;
		representative.DateOfIssue:= item.DateOfIssue;
		representative.PlaceOfIssue:= item.PlaceOfIssue;

		legalRepresentatives.Add(representative);
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

SaveEconomicData(EconomicData, UserName):= 
(
	if(!exists(EconomicData.RetailersNumber) or
		!exists(EconomicData.ExpectedMonthlyTurnover) or
		!exists(EconomicData.ExpectedYearlyTurnover) or
		!exists(EconomicData.ThreeMonthAccountTurnover) or
		!exists(EconomicData.CardPaymentPercentage) or
		!exists(EconomicData.AverageTransactionAmount) or
		!exists(EconomicData.AverageDailyTurnover) or
		!exists(EconomicData.CheapestProductAmount) or
		!exists(EconomicData.MostExpensiveProductAmount)) then 
		(
			BadRequest("Missing data");
		);

		economicData:= select top 1 * from POWRS.PaymentLink.Onboarding.EconomicData where UserName = UserName;
	    recordExists:= economicData != null;

		economicData.UserName:= UserName;
		economicData.RetailersNumber:= Int(EconomicData.RetailersNumber) ???  System.Decimal.Parse(0); 
		economicData.ExpectedMonthlyTurnover:= System.Decimal.Parse(EconomicData.ExpectedMonthlyTurnover) ??? System.Decimal.Parse(0);
		economicData.ExpectedYearlyTurnover:= System.Decimal.Parse(EconomicData.ExpectedYearlyTurnover) ??? System.Decimal.Parse(0);
		economicData.ThreeMonthAccountTurnover:= System.Decimal.Parse(EconomicData.ThreeMonthAccountTurnover) ??? System.Decimal.Parse(0);
		economicData.CardPaymentPercentage:= Int(EconomicData.CardPaymentPercentage) ??? 0;
		economicData.AverageDailyTurnover:= System.Decimal.Parse(EconomicData.AverageDailyTurnover) ??? System.Decimal.Parse(0);
		economicData.CheapestProductAmount:= System.Decimal.Parse(EconomicData.CheapestProductAmount) ??? System.Decimal.Parse(0);
		economicData.MostExpensiveProductAmount:= System.Decimal.Parse(EconomicData.MostExpensiveProductAmount) ??? System.Decimal.Parse(0);

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



SaveGeneralCompanyInfo(Posted.GeneralCompanyInfo, SessionUser.username);
SaveEconomicData(Posted.EconomicData, SessionUser.username);
