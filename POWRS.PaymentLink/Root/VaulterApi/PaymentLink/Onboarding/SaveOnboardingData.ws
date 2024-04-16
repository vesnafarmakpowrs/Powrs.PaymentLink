﻿SessionUser:= Global.ValidateAgentApiToken(false, false);

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
		!exists(EconomicData.BussinesModel) or
		!exists(EconomicData.SellingGoodsWithDelayedDelivery) or
		!exists(EconomicData.PeriodFromPaymentToDeliveryInDays) or
		!exists(EconomicData.ComplaintsPerMonth) or
		!exists(EconomicData.ComplaintsPerYear) or
		!exists(EconomicData.MostExpensiveProductAmount)) then 
		(
			BadRequest("Missing data");
		);

		economicData:= select top 1 * from POWRS.PaymentLink.Onboarding.EconomicData where UserName = UserName;
	    recordExists:= economicData != null;

		economicData.UserName:= UserName;
		economicData.RetailersNumber:= EconomicData.RetailersNumber;
		economicData.ExpectedMonthlyTurnover:= EconomicData.ExpectedMonthlyTurnover;
		economicData.ExpectedYearlyTurnover:= EconomicData.ExpectedYearlyTurnover;
		economicData.ThreeMonthAccountTurnover:= EconomicData.ThreeMonthAccountTurnover;
		economicData.CardPaymentPercentage:= Int(EconomicData.CardPaymentPercentage;
		economicData.AverageDailyTurnover:= EconomicData.AverageDailyTurnover;
		economicData.CheapestProductAmount:= EconomicData.CheapestProductAmount;
		economicData.MostExpensiveProductAmount:= EconomicData.MostExpensiveProductAmount;
		economicData.BussinesModel:= EconomicData.BussinesModel;
		economicData.SellingGoodsWithDelayedDelivery:= EconomicData.SellingGoodsWithDelayedDelivery;
		economicData.PeriodFromPaymentToDeliveryInDays:= EconomicData.PeriodFromPaymentToDeliveryInDays;
		economicData.ComplaintsPerMonth:= EconomicData.ComplaintsPerMonth;
		economicData.ComplaintsPerYear:= EconomicData.ComplaintsPerYear;

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



SaveGeneralCompanyInfo(Posted.GeneralCompanyInformation, SessionUser.username);
SaveEconomicData(Posted.EconomicData, SessionUser.username);