SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "SaveOnboardingData.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

if(Posted == null) then NotAcceptable("Data could not be null");

errors:= Create(System.Collections.Generic.List, System.String);
currentMethod:= "";
fileMaxSizeMB := GetSetting("POWRS.PaymentLink.OnBoardingFileMaxSize", "25");

allCompaniesRootPath := GetSetting("POWRS.PaymentLink.OnBoardingAllCompaniesRootPath","");
if(System.String.IsNullOrWhiteSpace(allCompaniesRootPath)) then (
	BadRequest("No setting: OnBoardingAllCompaniesRootPath");
);

ValidatePostedData(Posted) := (
	if(!exists(Posted.GeneralCompanyInformation) or Posted.GeneralCompanyInformation == null) then errors.Add("GeneralCompanyInformation could not be null");
	if(!exists(Posted.CompanyStructure) or Posted.CompanyStructure == null) then errors.Add("CompanyStructure could not be null");
	if(!exists(Posted.BusinessData) or Posted.BusinessData == null) then errors.Add("BusinessData could not be null");
	if(!exists(Posted.LegalDocuments) or Posted.LegalDocuments == null) then errors.Add("LegalDocuments could not be null");
	
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
	else if(Posted.GeneralCompanyInformation.OrganizationNumber not like "^\\d{8}$") then
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
	)else if (!System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.TaxNumber) and Posted.GeneralCompanyInformation.TaxNumber not like "^\\d{9}$")then(
		errors.Add("GeneralCompanyInformation.TaxNumber");
	);	
	if(!exists(Posted.GeneralCompanyInformation.ActivityNumber))then(
		errors.Add("GeneralCompanyInformation.ActivityNumber");
	)else if (!System.String.IsNullOrWhiteSpace(Posted.GeneralCompanyInformation.ActivityNumber) and Posted.GeneralCompanyInformation.ActivityNumber not like "^\\d{4}$")then(
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
				(!System.String.IsNullOrWhiteSpace(item.DateOfBirth) and item.DateOfBirth not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".DateOfBirth");
			);
			if(!exists(item.IsPoliticallyExposedPerson))then
			(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IsPoliticallyExposedPerson");
			);
			if(!exists(item.StatementOfOfficialDocumentIsNewUpload))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".StatementOfOfficialDocumentIsNewUpload");
			)else(
				isNewUpload := item.StatementOfOfficialDocumentIsNewUpload;
			);
			if(!exists(item.StatementOfOfficialDocument))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".StatementOfOfficialDocument");
			)else if (isNewUpload)then(
				if(!POWRS.PaymentLink.Utils.IsValidBase64String(item.StatementOfOfficialDocument, fileMaxSizeMB))then(
					errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".StatementOfOfficialDocument");
					errors.Add("StatementOfOfficialDocument not valid base 64 string");
				);
			);
			if(!System.String.IsNullOrWhiteSpace(item.StatementOfOfficialDocument) and System.String.IsNullOrWhiteSpace(item.FullName))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".FullName");
				errors.Add("When file exists full name must be populated");				
			);
			
			isNewUpload := false;
			if(!exists(item.IdCardIsNewUpload))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IdCardIsNewUpload");
			)else(
				isNewUpload := item.IdCardIsNewUpload;
			);
			if(!exists(item.IdCard))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IdCard");
			)else if(isNewUpload)then (
				if(System.String.IsNullOrWhiteSpace(item.IdCard))then (
					errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IdCard");
				)else if(!POWRS.PaymentLink.Utils.IsValidBase64String(item.IdCard, fileMaxSizeMB))then(
					errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".IdCard");
					errors.Add("IdCard not valid base 64 string");
				);
			);
			if(!System.String.IsNullOrWhiteSpace(item.IdCard) and System.String.IsNullOrWhiteSpace(item.FullName))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".FullName");
				errors.Add("When file exists full name must be populated");				
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
				if(!System.String.IsNullOrWhiteSpace(item.PersonalNumber))then
				(
					NormalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize("RS", item.PersonalNumber);
					isPersonalNumberValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid("RS", NormalizedPersonalNumber);

					if(item.PersonalNumber not like "^\\d{13}$" or isPersonalNumberValid != true) then 
					(
						errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + itemIndex + ".PersonalNumber");
					);
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
				if(!System.String.IsNullOrWhiteSpace(item.PersonalNumber))then
				(
					NormalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize("RS", item.PersonalNumber);
					isPersonalNumberValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid("RS", NormalizedPersonalNumber);

					if(item.PersonalNumber not like "^\\d{13}$" or isPersonalNumberValid != true) then 
					(
						errors.Add("CompanyStructure.Owners;" + itemIndex + ".PersonalNumber");
					);
				);
			);
			if(!exists(item.DateOfBirth) or 
				(!System.String.IsNullOrWhiteSpace(item.DateOfBirth) and item.DateOfBirth not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"))then
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
			if(!exists(item.StatementOfOfficialDocumentIsNewUpload))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".StatementOfOfficialDocumentIsNewUpload");
			)else(
				isNewUpload :=  item.StatementOfOfficialDocumentIsNewUpload ??? false;
			);
			if(!exists(item.StatementOfOfficialDocument))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".StatementOfOfficialDocument");
			)else if (isNewUpload)then(
				if(System.String.IsNullOrWhiteSpace(item.StatementOfOfficialDocument))then (
					errors.Add("CompanyStructure.Owners;" + itemIndex + ".StatementOfOfficialDocument");
				)else if(!POWRS.PaymentLink.Utils.IsValidBase64String(item.StatementOfOfficialDocument, fileMaxSizeMB))then(
					errors.Add("CompanyStructure.Owners;" + itemIndex + ".StatementOfOfficialDocument");
					errors.Add("StatementOfOfficialDocument not valid base 64 string");
				);
			);
			if(!System.String.IsNullOrWhiteSpace(item.StatementOfOfficialDocument) and System.String.IsNullOrWhiteSpace(item.FullName))then (
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".FullName");
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
			isNewUpload := false;			
			if(!exists(item.IdCardIsNewUpload))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IdCardIsNewUpload");
			)else(
				isNewUpload := item.IdCardIsNewUpload ??? false;
			);
			if(!exists(item.IdCard))then(
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".IdCard");
			)else if(isNewUpload)then (
				if(System.String.IsNullOrWhiteSpace(item.IdCard))then (
					errors.Add("CompanyStructure.Owners;" + itemIndex + ".IdCard");
				)else if(!POWRS.PaymentLink.Utils.IsValidBase64String(item.IdCard, fileMaxSizeMB))then(
					errors.Add("CompanyStructure.Owners;" + itemIndex + ".IdCard");
					errors.Add("IdCard not valid base 64 string");
				);
			);
			if(!System.String.IsNullOrWhiteSpace(item.IdCard) and System.String.IsNullOrWhiteSpace(item.FullName))then (
				errors.Add("CompanyStructure.Owners;" + itemIndex + ".FullName");
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
	
	isNewUpload := false;
	if(!exists(Posted.LegalDocuments.ContractWithEMIIsNewUpload))then(
		errors.Add("LegalDocuments.ContractWithEMIIsNewUpload");
	)else(
		isNewUpload := Posted.LegalDocuments.ContractWithEMIIsNewUpload; 
	);
	if(!exists(Posted.LegalDocuments.ContractWithEMI))then(
		errors.Add("LegalDocuments.ContractWithEMI");
	)else(
		if(isNewUpload and 
			(System.String.IsNullOrWhiteSpace(Posted.LegalDocuments.ContractWithEMI)
			or
			!POWRS.PaymentLink.Utils.IsValidBase64String(Posted.LegalDocuments.ContractWithEMI, fileMaxSizeMB)
			)
		)then
		(
			errors.Add("LegalDocuments.ContractWithEMI");
		);
	);
	
	isNewUpload := false;
	if(!exists(Posted.LegalDocuments.ContractWithVaulterIsNewUpload))then(
		errors.Add("LegalDocuments.ContractWithVaulterIsNewUpload");
	)else(
		isNewUpload := Posted.LegalDocuments.ContractWithVaulterIsNewUpload;
	);
	if(!exists(Posted.LegalDocuments.ContractWithVaulter))then(
		errors.Add("LegalDocuments.ContractWithVaulter");
	)else(
		if(isNewUpload and 
			(System.String.IsNullOrWhiteSpace(Posted.LegalDocuments.ContractWithVaulter)
			or
			!POWRS.PaymentLink.Utils.IsValidBase64String(Posted.LegalDocuments.ContractWithVaulter, fileMaxSizeMB)
			)
		)then
		(
			errors.Add("LegalDocuments.ContractWithVaulter");
		);
	);
	
	isNewUpload := false;
	if(!exists(Posted.LegalDocuments.PromissoryNoteIsNewUpload))then(
		errors.Add("LegalDocuments.PromissoryNoteIsNewUpload");
	)else(
		isNewUpload := Posted.LegalDocuments.PromissoryNoteIsNewUpload;
	);
	if(!exists(Posted.LegalDocuments.PromissoryNote))then(
		errors.Add("LegalDocuments.PromissoryNote");
	)else(
		if(isNewUpload and 
			(System.String.IsNullOrWhiteSpace(Posted.LegalDocuments.PromissoryNote)
			or
			!POWRS.PaymentLink.Utils.IsValidBase64String(Posted.LegalDocuments.PromissoryNote, fileMaxSizeMB)
			)
		)then
		(
			errors.Add("LegalDocuments.PromissoryNote");
		);
	);
	
	isNewUpload := false;
	if(!exists(Posted.LegalDocuments.BusinessCooperationRequestIsNewUpload))then(
		errors.Add("LegalDocuments.BusinessCooperationRequestIsNewUpload");
	)else(
		isNewUpload := Posted.LegalDocuments.BusinessCooperationRequestIsNewUpload;
	);
	if(!exists(Posted.LegalDocuments.BusinessCooperationRequest))then(
		errors.Add("LegalDocuments.BusinessCooperationRequest");
	)else(
		if(isNewUpload and 
			(System.String.IsNullOrWhiteSpace(Posted.LegalDocuments.BusinessCooperationRequest)
			or
			!POWRS.PaymentLink.Utils.IsValidBase64String(Posted.LegalDocuments.BusinessCooperationRequest, fileMaxSizeMB)
			)
		)then
		(
			errors.Add("LegalDocuments.BusinessCooperationRequest");
		);
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
	)
	else if(generalInfo.ShortName != newShortName) then
	(
		oldCompanySubDirPath := "\\" + generalInfo.ShortName;
		oldFileRootPath := allCompaniesRootPath + oldCompanySubDirPath;
				
		if(System.IO.Directory.Exists(oldFileRootPath)) then
		(
			System.IO.Directory.Move(oldFileRootPath, allCompaniesRootPath + "\\" + newShortName);
		);		
	);
	
	companySubDirPath := "\\" + newShortName;
	fileRootPath := allCompaniesRootPath + companySubDirPath;

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
			
			if(item.StatementOfOfficialDocumentIsNewUpload)then(
				fileName := "LegalRepresentative_" + Str(itemNo) + "_Politicall_" + item.FullName + ".pdf";
				SaveFile(fileRootPath, fileName, item.StatementOfOfficialDocument);
				
				representative.StatementOfOfficialDocument:= fileName;
			)else (
				if (item.StatementOfOfficialDocument != "" and !System.IO.File.Exists(fileRootPath + "\\" + item.StatementOfOfficialDocument)) then
				(
					Error("LegalRepresentative[" + Str(itemNo) + "] file " + item.StatementOfOfficialDocument + " does not exist");
				);
				representative.StatementOfOfficialDocument:= item.StatementOfOfficialDocument;
			);
			
			if(item.IdCardIsNewUpload)then(
				fileName := "LegalRepresentative_" + Str(itemNo) + "_IdCard_" + item.FullName + ".pdf";
				SaveFile(fileRootPath, fileName, item.IdCard);
				
				representative.IdCard:= fileName;
			)else(
				if (item.IdCard != "" and !System.IO.File.Exists(fileRootPath + "\\" + item.IdCard)) then
				(
					Error("LegalRepresentative[" + Str(itemNo) + "] file " + item.IdCard + " does not exist");
				);
				representative.IdCard:= item.IdCard;				
			);
			
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

SaveCompanyStructure(CompanyStructure, UserName, companyShortName):=
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
		companySubDirPath := "\\" + companyShortName;
		fileRootPath := allCompaniesRootPath + companySubDirPath;
		
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
			
			if(item.StatementOfOfficialDocumentIsNewUpload)then(
				fileName := "Owner_" + Str(itemNo) + "_Politicall_" + item.FullName + ".pdf";
				SaveFile(fileRootPath, fileName, item.StatementOfOfficialDocument);
				
				owner.StatementOfOfficialDocument:= fileName;
			)else (
				if (!System.String.IsNullOrWhiteSpace(item.StatementOfOfficialDocument) and !System.IO.File.Exists(fileRootPath + "\\" + item.StatementOfOfficialDocument)) then
				(
					Error("Owner[" + Str(itemNo) + "] file " + item.StatementOfOfficialDocument + " does not exist");
				);
				owner.StatementOfOfficialDocument:= item.StatementOfOfficialDocument;
			);
			
			if(item.IdCardIsNewUpload)then(
				fileName := "Owner_" + Str(itemNo) + "_IdCard_" + item.FullName + ".pdf";
				SaveFile(fileRootPath, fileName, item.IdCard);
				
				owner.IdCard:= fileName;
			)else(
				if (!System.String.IsNullOrWhiteSpace(item.IdCard) and !System.IO.File.Exists(fileRootPath + "\\" + item.IdCard)) then
				(
					Error("Owner[" + Str(itemNo) + "] file " + item.IdCard + " does not exist");
				);
				owner.IdCard:= item.IdCard;				
			);

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

SaveLegalDocuments(LegalDocuments, UserName, companyShortName):=
(
	companySubDirPath := "\\" + companyShortName;
	fileRootPath := allCompaniesRootPath + companySubDirPath;
	

	documents:= select top 1 * from POWRS.PaymentLink.Onboarding.LegalDocuments where UserName = UserName;
	alreadyExists:= documents != null;

	if(documents == null) then 
	(
		documents:= Create(POWRS.PaymentLink.Onboarding.LegalDocuments, UserName);
	);

	if(LegalDocuments.ContractWithEMIIsNewUpload) then
	(
		fileName := "ContractWithEMI" + ".pdf";
		SaveFile(fileRootPath, fileName, LegalDocuments.ContractWithEMI);
		documents.ContractWithEMI:=  fileName;
	)else (
		if (LegalDocuments.ContractWithEMI != "" and !System.IO.File.Exists(fileRootPath + "\\" + LegalDocuments.ContractWithEMI)) then
		(
			Error("ContractWithEMI file " + LegalDocuments.ContractWithEMI + " does not exist");
		);
		documents.ContractWithEMI:= LegalDocuments.ContractWithEMI;
	);
	
	if(LegalDocuments.ContractWithVaulterIsNewUpload) then
	(
		fileName := "ContractWithVaulter" + ".pdf";
		SaveFile(fileRootPath, fileName, LegalDocuments.ContractWithVaulter);
		documents.ContractWithVaulter:= fileName;
	)else (
		if (LegalDocuments.ContractWithVaulter != "" and !System.IO.File.Exists(fileRootPath + "\\" + LegalDocuments.ContractWithVaulter)) then
		(
			Error("ContractWithVaulter file " + LegalDocuments.ContractWithVaulter + " does not exist");
		);
		documents.ContractWithVaulter:= LegalDocuments.ContractWithVaulter;
	);
	
	if(LegalDocuments.PromissoryNoteIsNewUpload) then
	(
		fileName := "PromissoryNote" + ".pdf";
		SaveFile(fileRootPath, fileName, LegalDocuments.PromissoryNote);
		documents.PromissoryNote:= fileName;
	)else (
		if (LegalDocuments.PromissoryNote != "" and !System.IO.File.Exists(fileRootPath + "\\" + LegalDocuments.PromissoryNote)) then
		(
			Error("PromissoryNote file " + LegalDocuments.PromissoryNote + " does not exist");
		);
		documents.PromissoryNote:= LegalDocuments.PromissoryNote;
	);
	
	if(LegalDocuments.BusinessCooperationRequestIsNewUpload) then
	(
		fileName := "BusinessCooperationRequest" + ".pdf";
		SaveFile(fileRootPath, fileName, LegalDocuments.BusinessCooperationRequest);
		documents.BusinessCooperationRequest:= fileName;
	)else (
		if (LegalDocuments.BusinessCooperationRequest != "" and !System.IO.File.Exists(fileRootPath + "\\" + LegalDocuments.BusinessCooperationRequest)) then
		(
			Error("BusinessCooperationRequest file " + LegalDocuments.BusinessCooperationRequest + " does not exist");
		);
		documents.BusinessCooperationRequest:= LegalDocuments.BusinessCooperationRequest;
	);

	if(alreadyExists) then 
	(
		Waher.Persistence.Database.Update(documents);
	)
	else
	(
		Waher.Persistence.Database.Insert(documents);
	);

	Return(0);
);

SaveFile(fileRootPath, fileName, fileBase64String):=
(
	if (!System.IO.Directory.Exists(fileRootPath)) then(
		System.IO.Directory.CreateDirectory(fileRootPath);
	);
	
	filePath := fileRootPath + "\\" + fileName;
	fileBytes := System.Convert.FromBase64String(fileBase64String);
	
	System.IO.File.WriteAllBytes(filePath, fileBytes);
	
	return(1);
);

try
(
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);
	
	currentMethod := "SaveGeneralCompanyInfo"; 
	SaveGeneralCompanyInfo(Posted.GeneralCompanyInformation, SessionUser.username);
	
	currentMethod := "SaveCompanyStructure"; 
	SaveCompanyStructure(Posted.CompanyStructure, SessionUser.username, Trim(Posted.GeneralCompanyInformation.ShortName));
	
	currentMethod := "SaveBusinessData"; 
	SaveBusinessData(Posted.BusinessData, SessionUser.username);
	
	currentMethod := "SaveLegalDocuments"; 
	SaveLegalDocuments(Posted.LegalDocuments, SessionUser.username, Trim(Posted.GeneralCompanyInformation.ShortName));
	
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