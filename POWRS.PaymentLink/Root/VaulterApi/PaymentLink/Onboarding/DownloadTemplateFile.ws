SessionUser:= Global.ValidateAgentApiToken(false, false);

({
	"FileType": Required(Str(PFileType)),
	"IsEmptyFile":  Required(Boolean(PIsEmptyFile)),
	"PersonPositionInCompany": Optional(Str(PPersonPositionInCompany)),
	"PersonIndex": Optional(Int(PPersonIndex))
}:= Posted) ??? BadRequest(Exception.Message);

logObjectID := SessionUser.username;
logEventID := "DownloadTemplateFile.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

DownloadTemplateContractWithVaulter(PIsEmptyFile) := (
	Log.Informational("Method DTContractWithVaulter started", logObjectID, logActor, logEventID, null);

	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	if(generalInfo == null)then
	(
		Error("GeneralCompanyInformation must be populated");
	);
	if(generalInfo.LegalRepresentatives == null or generalInfo.LegalRepresentatives.Length == 0)then
	(
		Error("LegalRepresentatives must be populated");
	);

	newPDFFilePath := "";
	
	templateFileName := "ContractPowrs";
	newFileName := "New_ContractPowrs";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\Powrs";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!File.Exists(htmlTemplatePath)) then
	(
		Error("File does not exist");
	);
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	if(PIsEmptyFile)then
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(naziv)");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(adresa)");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyRepresenter}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	)
	else
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.CompanyAddress + " " + generalInfo.CompanyCity + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.OrganizationNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.TaxNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyRepresenter}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.LegalRepresentatives[0].FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	);
	
	Log.Informational("Method DTContractWithVaulter. finish HTML replacement. Try to start method CreatePDFFile()", logObjectID, logActor, logEventID, null);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Log.Informational("finish method CreatePDFFile. return newPDFFilePath: " + newPDFFilePath, logObjectID, logActor, logEventID, null);
		
	Return (newPDFFilePath);
);

DownloadTemplateBusinessCooperationRequest(PIsEmptyFile) := (
	Log.Informational("Method DTBusinessCooperationRequest started", logObjectID, logActor, logEventID, null);

	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	if(generalInfo == null)then
	(
		Error("GeneralCompanyInformation must be populated");
	);
	companyStructure:= select top 1 * from POWRS.PaymentLink.Onboarding.CompanyStructure where UserName = SessionUser.username;
	if(companyStructure == null or companyStructure.Owners == null or companyStructure.Owners.Length == 0)then
	(
		Error("CompanyStructure and owners must be populated");
	);
	
	businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = SessionUser.username;

	newPDFFilePath := "";
	
	templateFileName := "BusinessCooperationRequest";
	newFileName := "New_BusinessCooperationRequest";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!File.Exists(htmlTemplatePath)) then
	(
		Error("File does not exist");
	);
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	if(PIsEmptyFile)then
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "");
		htmlContent := htmlContent.Replace("{{CompanyShortName}}", "");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "");
		htmlContent := htmlContent.Replace("{{ActivityNumber}}", "");
		htmlContent := htmlContent.Replace("{{OtherCompanyActivitiesYesNo}}", "Da / Ne");
		
		htmlContent := htmlContent.Replace("{{LegalRepresentativeFullName}}", "");
		htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfBirth}}", "");
		htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfBirth}}", "");
		htmlContent := htmlContent.Replace("{{LegalRepresentativeDocumentType}}", "Lična karta / Pasoš");
		htmlContent := htmlContent.Replace("{{LegalRepresentativeDocumentNumber}}", "");
		htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfIssue}}", "");
		htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfIssue}}", "");
		htmlContent := htmlContent.Replace("{{LegalRepresentativeHaveMoreThenOne}}", "Da / Ne");
		
		htmlContent := htmlContent.Replace("{{CompanyContactPerson}}", "");
		htmlContent := htmlContent.Replace("{{CompanyTelephone}}", "");
		htmlContent := htmlContent.Replace("{{CompanyEmail}}", "");
		htmlContent := htmlContent.Replace("{{CompanyWebAdresa}}", "");
		htmlContent := htmlContent.Replace("{{CompanyAccountNumberAndBank}}", "");
		
		htmlContent := htmlContent.Replace("{{CountriesOfBusiness}}", "");
		htmlContent := htmlContent.Replace("{{ExpectedMonthlyTurnover}}", "");
		htmlContent := htmlContent.Replace("{{StampUsage}}", "Koristi pečat / Ne koristi pečat");
		
		htmlContent := htmlContent.Replace("{{OwnerStructure}}", "Fizička lica / Pravna lica / Fizička i pravna lica");
		htmlContent := htmlContent.Replace("{{PoliticallyExposedPerson}}", "Da / Ne <br /> <br /> Funkcioner RS / Funkcioner druge države ili međunarodne organizacije / Bliski saradnik funkcionera / Srodnik funkcionera");
		htmlContent := htmlContent.Replace("{{OffShoreFoundationInOwnerStructure}}", "Da / Ne");
		htmlContent := htmlContent.Replace("{{NameOfTheForeignExchangeAndIDNumber}}", "");
	
		htmlContent := htmlContent.Replace("{{ShowOwners}}", "showDiv");
		htmlContent := htmlContent.Replace("{{OwnerStructureTable}}", "");
		htmlContent := htmlContent.Replace("{{ShowOtherCompanyActivities}}", "showDiv");
		htmlContent := htmlContent.Replace("{{OtherCompanyActivities}}", "");
		htmlContent := htmlContent.Replace("{{ShowLegalRepresentatives}}", "showDiv");
		htmlContent := htmlContent.Replace("{{LegalRepresentativesStr}}", "");
	
	)
	else
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", generalInfo.FullName);
		htmlContent := htmlContent.Replace("{{CompanyShortName}}", generalInfo.ShortName);
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", generalInfo.CompanyAddress);
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", generalInfo.OrganizationNumber);
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", generalInfo.TaxNumber);
		htmlContent := htmlContent.Replace("{{ActivityNumber}}", generalInfo.ActivityNumber);
		htmlContent := htmlContent.Replace("{{OtherCompanyActivitiesYesNo}}", generalInfo.OtherCompanyActivities != "" ? "DA" : "NE");
		
		
		if(generalInfo.LegalRepresentatives != null and generalInfo.LegalRepresentatives.Length > 0) then
		(
			htmlContent := htmlContent.Replace("{{LegalRepresentativeFullName}}", generalInfo.LegalRepresentatives[0].FullName);
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfBirth}}", generalInfo.LegalRepresentatives[0].DateOfBirthStr);
			htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfBirth}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDocumentType}}", generalInfo.LegalRepresentatives[0].DocumentType == POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard ? "Lična karta" : "Pasoš");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDocumentNumber}}", generalInfo.LegalRepresentatives[0].DocumentNumber);
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfIssue}}", generalInfo.LegalRepresentatives[0].DateOfIssueStr);
			htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfIssue}}", generalInfo.LegalRepresentatives[0].PlaceOfIssue);
			htmlContent := htmlContent.Replace("{{LegalRepresentativeHaveMoreThenOne}}", generalInfo.LegalRepresentatives.Length > 1 ? "Da" : "Ne");
		)
		else 
		(
			htmlContent := htmlContent.Replace("{{LegalRepresentativeFullName}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfBirth}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfBirth}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDocumentType}}", "Lična karta / Pasoš");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDocumentNumber}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfIssue}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfIssue}}", "");
			htmlContent := htmlContent.Replace("{{LegalRepresentativeHaveMoreThenOne}}", "Da / Ne");
		);
		
		htmlContent := htmlContent.Replace("{{CompanyContactPerson}}", "");
		htmlContent := htmlContent.Replace("{{CompanyTelephone}}", "");
		htmlContent := htmlContent.Replace("{{CompanyEmail}}", "");
		htmlContent := htmlContent.Replace("{{CompanyWebAdresa}}", generalInfo.CompanyWebsite);
		htmlContent := htmlContent.Replace("{{CompanyAccountNumberAndBank}}", generalInfo.BankAccountNumber + " " + generalInfo.BankName);
		
		countriesOfBusiness := "";
		i := 1;
		foreach (item in companyStructure.CountriesOfBusiness) do(
		   countriesOfBusiness += Str(item) + (i !=  companyStructure.CountriesOfBusiness.Length ? ", " : "");
		   i++;
		);
		htmlContent := htmlContent.Replace("{{CountriesOfBusiness}}", countriesOfBusiness);
		if(businessData != null and businessData.ExpectedMonthlyTurnover > 0)then(
			htmlContent := htmlContent.Replace("{{ExpectedMonthlyTurnover}}", Str(businessData.ExpectedMonthlyTurnover));
		)
		else(
			htmlContent := htmlContent.Replace("{{ExpectedMonthlyTurnover}}", "");
		);
		htmlContent := htmlContent.Replace("{{StampUsage}}", generalInfo.StampUsage ? "Koristi pečat" : "Ne koristi pečat");		
		
		ownerStructure := "";
		if(companyStructure.OwnerStructure == POWRS.PaymentLink.Onboarding.Enums.OwnerStructure.Person)then
		(
			ownerStructure := "Fizička lica";
		)
		else if(companyStructure.OwnerStructure == POWRS.PaymentLink.Onboarding.Enums.OwnerStructure.Company)then 
		(
			ownerStructure := "Pravna lica";
		)
		else 
		(
			ownerStructure := "Fizička i pravna lica";
		);
		
		htmlContent := htmlContent.Replace("{{OwnerStructure}}", ownerStructure);
		
		isPoliticallyExposedPerson := false;
		foreach (item in generalInfo.LegalRepresentatives) do(
		   if(item.IsPoliticallyExposedPerson)then
		   (
				isPoliticallyExposedPerson := true;
		   );
		);
		
		if(!isPoliticallyExposedPerson)then
		(
			foreach (item in companyStructure.Owners) do(
				if(item.IsPoliticallyExposedPerson)then
				(
					isPoliticallyExposedPerson := true;
				);
			);
		);
		
		htmlContent := htmlContent.Replace("{{PoliticallyExposedPerson}}", !isPoliticallyExposedPerson ? "Ne" : "Da<br /><br />Funkcioner RS / Funkcioner druge države ili međunarodne organizacije / Bliski saradnik funkcionera / Srodnik funkcionera");
		htmlContent := htmlContent.Replace("{{OffShoreFoundationInOwnerStructure}}", companyStructure.OffShoreFoundationInOwnerStructure ? "Da" : "Ne");
		htmlContent := htmlContent.Replace("{{NameOfTheForeignExchangeAndIDNumber}}", companyStructure.NameOfTheForeignExchangeAndIDNumber);
		
		if(companyStructure.Owners != null and companyStructure.Owners.Length > 0) then 
		(
			htmlContent := htmlContent.Replace("{{ShowOwners}}", "showDiv");
			ownerStructureTable := "";
			foreach (item in companyStructure.Owners) do(
				ownerStructureTable += "<tr>";
				ownerStructureTable += "<td>" + item.FullName + "</td>";
				ownerStructureTable += "<td>" + item.AddressAndPlaceOfResidence + "</td>";
				ownerStructureTable += "<td>" + item.DateOfBirthStr + "</td>";
				ownerStructureTable += "<td>" + item.Citizenship + "</td>";
				ownerStructureTable += "<td>" + item.OwningPercentage + "</td>";
				ownerStructureTable += "<td>" + item.Role + "</td>";
				ownerStructureTable += "</tr>";
			);
			
			htmlContent := htmlContent.Replace("{{OwnerStructureTable}}", ownerStructureTable);
		)else 
		(
			htmlContent := htmlContent.Replace("{{ShowOwners}}", "hideDiv");
			ownerStructureTable := "<tr><td></td><td></td><td></td><td></td><td></td><td></td></tr>";
			ownerStructureTable += "<tr><td></td><td></td><td></td><td></td><td></td><td></td></tr>";
			htmlContent := htmlContent.Replace("{{OwnerStructureTable}}", ownerStructureTable);
		);
		
		if(generalInfo.OtherCompanyActivities != "")then
		(
			htmlContent := htmlContent.Replace("{{ShowOtherCompanyActivities}}", "showDiv");
			htmlContent := htmlContent.Replace("{{OtherCompanyActivities}}", generalInfo.OtherCompanyActivities);
		)else 
		(
			htmlContent := htmlContent.Replace("{{ShowOtherCompanyActivities}}", "hideDiv");
			htmlContent := htmlContent.Replace("{{OtherCompanyActivities}}", "");
		);
		
		if(generalInfo.LegalRepresentatives != null and generalInfo.LegalRepresentatives.Length > 1) then
		(
			legalRepresentativesStr := "";
			FOR i := 1 TO generalInfo.LegalRepresentatives.Length - 1 STEP 1 DO
			(
				legalRepresentativesStr +=  generalInfo.LegalRepresentatives[i].FullName + (i != generalInfo.LegalRepresentatives.Length ? ", " : "");
			);
		
			htmlContent := htmlContent.Replace("{{ShowLegalRepresentatives}}", "showDiv");
			htmlContent := htmlContent.Replace("{{LegalRepresentativesStr}}", legalRepresentativesStr);
		)else 
		(
			htmlContent := htmlContent.Replace("{{ShowLegalRepresentatives}}", "hideDiv");
			htmlContent := htmlContent.Replace("{{LegalRepresentativesStr}}", "");
		);
	);
	
	Log.Informational("Method TBusinessCooperationRequest. finish HTML replacement. Try to start method CreatePDFFile()", logObjectID, logActor, logEventID, null);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Log.Informational("finish method CreatePDFFile. return newPDFFilePath: " + newPDFFilePath, logObjectID, logActor, logEventID, null);
		
	Return (newPDFFilePath);
);

DownloadTemplateContractWithEMI(PIsEmptyFile) := (
	Log.Informational("Method DTContractWithEMI started", logObjectID, logActor, logEventID, null);

	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	if(generalInfo == null)then
	(
		Error("GeneralCompanyInformation must be populated");
	);
	if(generalInfo.LegalRepresentatives == null or generalInfo.LegalRepresentatives.Length == 0)then
	(
		Error("LegalRepresentatives must be populated");
	);

	newPDFFilePath := "";
	
	templateFileName := "ContractPaySpot";
	newFileName := "New_ContractPaySpot";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!File.Exists(htmlTemplatePath)) then
	(
		Error("File does not exist");
	);
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	if(PIsEmptyFile)then
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(naziv)");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(adresa)");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyRepresenter}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	)
	else
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.CompanyAddress + " " + generalInfo.CompanyCity + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.OrganizationNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.TaxNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyRepresenter}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.LegalRepresentatives[0].FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	);
	
	Log.Informational("Method DTContractWithEMI. finish HTML replacement. Try to start method CreatePDFFile()", logObjectID, logActor, logEventID, null);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Log.Informational("finish method CreatePDFFile. return newPDFFilePath: " + newPDFFilePath, logObjectID, logActor, logEventID, null);
		
	Return (newPDFFilePath);
);

DownloadTemplateStatementOfOfficialDocument(PIsEmptyFile, PPersonPositionInCompany, PPersonIndex) := (
	Log.Informational("Method DTStatementOfOfficialDocument started", logObjectID, logActor, logEventID, null);

	newPDFFilePath := "";
	
	templateFileName := "StatementOfOfficialDocument";
	newFileName := "New_StatementOfOfficialDocument";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!File.Exists(htmlTemplatePath)) then
	(
		Error("File does not exist");
	);
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	if(PIsEmptyFile)then
	(
		htmlContent := htmlContent.Replace("{{ClientFullName}}", "");
		htmlContent := htmlContent.Replace("{{PersonalNumber}}", "");
		htmlContent := htmlContent.Replace("{{DateAndPlaceOfBirth}}", "");
		htmlContent := htmlContent.Replace("{{AddressAndPlaceOfResidence}}", "");
		htmlContent := htmlContent.Replace("{{CityOdResidence}}", "");
		htmlContent := htmlContent.Replace("{{DocumentTypeAndNumber}}", "");
		htmlContent := htmlContent.Replace("{{DocumentIssueDate}}", "");
		htmlContent := htmlContent.Replace("{{DocumentIssuerName}}", "");
		
		htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_Yes}}", "");
		htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "");
		htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_Yes}}", "");
		htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_No}}", "");
	)
	else
	(
		if(PPersonPositionInCompany == "LegalRepresentative")then
		(
			generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
			if(generalInfo == null)then
			(
				Error("GeneralCompanyInformation must be populated");
			);
			if(generalInfo.LegalRepresentatives == null or generalInfo.LegalRepresentatives.Length < PPersonIndex + 1)then
			(
				Error("LegalRepresentatives must be populated");
			);
			
			htmlContent := htmlContent.Replace("{{ClientFullName}}", generalInfo.LegalRepresentatives[PPersonIndex].FullName);
			htmlContent := htmlContent.Replace("{{PersonalNumber}}", "");
			htmlContent := htmlContent.Replace("{{DateAndPlaceOfBirth}}", generalInfo.LegalRepresentatives[PPersonIndex].DateOfBirthStr + ", ");
			htmlContent := htmlContent.Replace("{{AddressAndPlaceOfResidence}}", "");
			htmlContent := htmlContent.Replace("{{CityOdResidence}}", "");
			htmlContent := htmlContent.Replace("{{DocumentTypeAndNumber}}", (generalInfo.LegalRepresentatives[PPersonIndex].DocumentType == POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard ? "Lična karta" : "Pasoš") + ", " + generalInfo.LegalRepresentatives[PPersonIndex].DocumentNumber);
			htmlContent := htmlContent.Replace("{{DocumentIssueDate}}", generalInfo.LegalRepresentatives[PPersonIndex].DateOfIssueStr + ", " + generalInfo.LegalRepresentatives[PPersonIndex].PlaceOfIssue);
			htmlContent := htmlContent.Replace("{{DocumentIssuerName}}", "");
			
			if (generalInfo.LegalRepresentatives[PPersonIndex].IsPoliticallyExposedPerson)then
			(
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_Yes}}", "checked");
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_No}}", "");
			)
			else
			(
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_No}}", "");
			);
		)
		else
		(
			companyStructure:= select top 1 * from POWRS.PaymentLink.Onboarding.CompanyStructure where UserName = SessionUser.username;
			if(companyStructure == null or companyStructure.Owners == null or companyStructure.Owners.Length < PPersonIndex + 1)then
			(
				Error("CompanyStructure and owners must be populated");
			);
		
			htmlContent := htmlContent.Replace("{{ClientFullName}}", companyStructure.Owners[PPersonIndex].FullName);
			htmlContent := htmlContent.Replace("{{PersonalNumber}}", companyStructure.Owners[PPersonIndex].PersonalNumber);
			htmlContent := htmlContent.Replace("{{DateAndPlaceOfBirth}}", companyStructure.Owners[PPersonIndex].DateOfBirthStr + ", " + companyStructure.Owners[PPersonIndex].PlaceOfBirth);
			htmlContent := htmlContent.Replace("{{AddressAndPlaceOfResidence}}", companyStructure.Owners[PPersonIndex].AddressAndPlaceOfResidence);
			htmlContent := htmlContent.Replace("{{CityOdResidence}}", "");
			htmlContent := htmlContent.Replace("{{DocumentTypeAndNumber}}", (companyStructure.Owners[PPersonIndex].DocumentType == POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard ? "Lična karta" : "Pasoš") + ", " + companyStructure.Owners[PPersonIndex].DocumentNumber);
			htmlContent := htmlContent.Replace("{{DocumentIssueDate}}", companyStructure.Owners[PPersonIndex].DateOfIssueStr + ", " + companyStructure.Owners[PPersonIndex].PlaceOfIssue);
			htmlContent := htmlContent.Replace("{{DocumentIssuerName}}", companyStructure.Owners[PPersonIndex].IssuerName);
			
			if (companyStructure.Owners[PPersonIndex].IsPoliticallyExposedPerson)then
			(
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_Yes}}", "checked");
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_No}}", "");
			)
			else
			(
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_No}}", "");
			);
		);
	);
	
	Log.Informational("Method DTStatementOfOfficialDocument. finish HTML replacement. Try to start method CreatePDFFile()", logObjectID, logActor, logEventID, null);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Log.Informational("finish method CreatePDFFile. return newPDFFilePath: " + newPDFFilePath, logObjectID, logActor, logEventID, null);
		
	Return (newPDFFilePath);
);

CreatePDFFile(fileRootPath, newFileName, htmlContent) := (
	newHtmlPath:= fileRootPath + "\\" + newFileName + ".html";
	Log.Informational("Method CreatePDFFile. newHtmlPath: " + newHtmlPath, logObjectID, logActor, logEventID, null);
	System.IO.File.WriteAllText(newHtmlPath, htmlContent, System.Text.Encoding.UTF8);
	Log.Informational("Method CreatePDFFile. created new HTML file", logObjectID, logActor, logEventID, null);
	newPDFFilePath:= fileRootPath + "\\" + newFileName + ".pdf";
	
	ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
		"--allow \"" + fileRootPath + "\""
		+ " \"" + newHtmlPath + "\"" 
		+ " \"" +  newPDFFilePath + "\""
		, fileRootPath);
	
	Log.Informational("Method CreatePDFFile. created PDF file. newPDFFilePath: " + newPDFFilePath, logObjectID, logActor, logEventID, null);
	
	Return (newPDFFilePath);
);

try 
(	
	templateFileTypeList := Create(System.Collections.Generic.List, System.String);
	templateFileTypeList.Add("ContractWithVaulter");
	templateFileTypeList.Add("ContractWithEMI");
	templateFileTypeList.Add("StatementOfOfficialDocument");
	templateFileTypeList.Add("BusinessCooperationRequest");
	templateFileTypeList.Add("PromissoryNote");
	
	if(!templateFileTypeList.Contains(PFileType))then
	(
		BadRequest("Parameter FileType not valid");
	);
	
	allCompaniesRootPath := GetSetting("POWRS.PaymentLink.OnBoardingFileRootPath","");
	if(System.String.IsNullOrWhiteSpace(allCompaniesRootPath)) then (
		Error("No setting: OnBoardingFileRootPath");
	);	
	
	returnFilePath := "";
	fileName := "";
	if(PFileType == "ContractWithVaulter")then
	(
		returnFilePath := DownloadTemplateContractWithVaulter(PIsEmptyFile);
		fileName := "Ugovor Powrs-Vaulter.pdf";
	)
	else if (PFileType == "BusinessCooperationRequest") then 
	(
		returnFilePath := DownloadTemplateBusinessCooperationRequest(PIsEmptyFile);
		fileName := "Zahtev za uspostavljanje saradnje.pdf";		
	)
	else if (PFileType == "ContractWithEMI") then 
	(
		returnFilePath := DownloadTemplateContractWithEMI(PIsEmptyFile);
		fileName := "Ugovor PaySpot.pdf";		
	)
	else if (PFileType == "StatementOfOfficialDocument") then 
	(
		if (System.String.IsNullOrWhiteSpace(PPersonPositionInCompany) or !exists(PPersonIndex))then(
			Error("Person Position and Person Index must be entered");
		);
		
		personPositionList := Create(System.Collections.Generic.List, System.String);
		personPositionList.Add("LegalRepresentative");
		personPositionList.Add("Owner");
		
		if(!personPositionList.Contains(PPersonPositionInCompany))then
		(
			BadRequest("Parameter PersonPositionInCompany not valid");
		);
		
		returnFilePath := DownloadTemplateStatementOfOfficialDocument(PIsEmptyFile, PPersonPositionInCompany, PPersonIndex);
		fileName := "Izjava funkcionera_" + PPersonPositionInCompany + "_" + Str(PPersonIndex) + ".pdf";		
	)
	else if (PFileType == "PromissoryNote") then 
	(
		returnFilePath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PromissoryNoteIntruction.pdf";
		fileName := "PromissoryNoteIntruction.pdf";
	);
	
	Log.Informational("Finished metod generate PDF. result returnFilePath: " + returnFilePath, logObjectID, logActor, logEventID, null);
		
    bytes := System.IO.File.ReadAllBytes(returnFilePath);
	Log.Informational("Succeffully returned file:" + PFileType, logObjectID, logActor, logEventID, null);
	
	{
		Name: fileName,
		File: bytes
	}
)
catch 
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
