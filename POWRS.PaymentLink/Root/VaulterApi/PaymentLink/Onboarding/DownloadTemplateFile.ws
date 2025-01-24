SessionUser:= Global.ValidateAgentApiToken(false, false);

({
	"FileType": Required(Str(PFileType)),
	"IsEmptyFile":  Required(Boolean(PIsEmptyFile)),
	"PersonPositionInCompany": Optional(Str(PPersonPositionInCompany)),
	"PersonIndex": Optional(Int(PPersonIndex))
}:= Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "DownloadTemplateFile.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];
errors:= Create(System.Collections.Generic.List, System.String);

DownloadTemplateContractWithVaulter(PIsEmptyFile) := (
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
	if (!System.IO.File.Exists(htmlTemplatePath)) then
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
		if(System.String.IsNullOrWhiteSpace(generalInfo.FullName))then(
			errors.Add("GeneralCompanyInformation.FullName");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.CompanyAddress))then(
			errors.Add("GeneralCompanyInformation.CompanyAddress");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.CompanyCity))then(
			errors.Add("GeneralCompanyInformation.CompanyCity");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.OrganizationNumber))then(
			errors.Add("GeneralCompanyInformation.OrganizationNumber");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.TaxNumber))then(
			errors.Add("GeneralCompanyInformation.TaxNumber");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[0].FullName))then(
			errors.Add("GeneralCompanyInformation.LegalRepresentatives;0.FullName");
		);
		
		if(errors.Count > 0)then
		(
			Error(errors);
			return (0);
		);
	
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.CompanyAddress + ", " + generalInfo.CompanyCity + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.OrganizationNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.TaxNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyRepresenter}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.LegalRepresentatives[0].FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
		
	Return (newPDFFilePath);
);

DownloadTemplateBusinessCooperationRequest(PIsEmptyFile) := (
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	if(generalInfo == null)then
	(
		Error("GeneralCompanyInformation must be populated");
	);
	companyStructure:= select top 1 * from POWRS.PaymentLink.Onboarding.CompanyStructure where UserName = SessionUser.username;
	if(companyStructure == null or 
		(companyStructure.OwnerStructure != POWRS.PaymentLink.Onboarding.Enums.OwnerStructure.Person 
			and 
			(companyStructure.Owners == null or companyStructure.Owners.Length == 0)
		)
	)then
	(
		Error("CompanyStructure and owners must be populated");
	);
	
	businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = SessionUser.username;

	newPDFFilePath := "";
	
	templateFileName := "BusinessCooperationRequest";
	newFileName := "New_BusinessCooperationRequest";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!System.IO.File.Exists(htmlTemplatePath)) then
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
		
		
		htmlContent := htmlContent.Replace("{{chBoxInternetPlatforma}}", "");
		htmlContent := htmlContent.Replace("{{chBoxInternetProdajnoMesto}}", "");
		htmlContent := htmlContent.Replace("{{EComerceContactFullName}}", "");
		htmlContent := htmlContent.Replace("{{EComerceResponsiblePersonPhone}}", "");
		htmlContent := htmlContent.Replace("{{EComerceContactEmail}}", "");
		htmlContent := htmlContent.Replace("{{CompanyWebshop}}", "");
		htmlContent := htmlContent.Replace("{{RetailersNumber}}", "");
		htmlContent := htmlContent.Replace("{{PercentageOfForeignUsers}}", "");
		htmlContent := htmlContent.Replace("{{AverageTransactionAmount}}", "");
		htmlContent := htmlContent.Replace("{{AverageDailyTurnover}}", "");
		htmlContent := htmlContent.Replace("{{ThreeMonthAccountTurnover}}", "");
		htmlContent := htmlContent.Replace("{{CardPaymentPercentage}}", "");
		htmlContent := htmlContent.Replace("{{DescriptionOfTheGoodsToBeSoldOnline}}", "");
		htmlContent := htmlContent.Replace("{{MethodOfDeliveringGoodsToCustomers}}", "");
		htmlContent := htmlContent.Replace("{{ExpectedYearlyTurnover}}", "");
		htmlContent := htmlContent.Replace("{{CheapestProductAmount}}", "");
		htmlContent := htmlContent.Replace("{{MostExpensiveProductAmount}}", "");
		htmlContent := htmlContent.Replace("{{SellingGoodsWithDelayedDelivery}}", "");
		htmlContent := htmlContent.Replace("{{PeriodFromPaymentToDeliveryInDays}}", "");
		htmlContent := htmlContent.Replace("{{DoYouHaveCustomerComplaints}}", "");
		htmlContent := htmlContent.Replace("{{ComplaintsPerMonth}}", "");
		htmlContent := htmlContent.Replace("{{ComplaintsPerYear}}", "");
		htmlContent := htmlContent.Replace("{{BusinessModel}}", "");
		
		
		htmlContent := htmlContent.Replace("{{showHideOtherLegalRepresentatives}}", "showDiv");
		htmlContent := htmlContent.Replace("{{pagebreak}}", "pagebreak");
		otherLegalRepresentativesTable := Create(System.Text.StringBuilder);
		FOR i := 1 TO 4 STEP 1 DO
		(
			otherLegalRepresentativesTable.Append("<br />");
			otherLegalRepresentativesTable.Append("<div>" + Str(i) + "</div>");
			otherLegalRepresentativesTable.Append("<table class=\"tbl2\">");
			otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Ime i prezime zastupnika</td><td></td></tr>");
			otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Datum i mesto rođenja</td><td></td></tr>");
			otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Vrsta ličnog dokumenta i broj</td><td></td></tr>");
			otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Datum i mesto izdavanja ličnog dokumenta</td><td></td></tr>");
			otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Boravište/Prebivalište</td><td></td></tr>");
			otherLegalRepresentativesTable.Append("</table>");
			otherLegalRepresentativesTable.Append("<br />");
		);
		htmlContent := htmlContent.Replace("{{OtherLegalRepresentativesTable}}", otherLegalRepresentativesTable.ToString());
		destroy(otherLegalRepresentativesTable);
	)
	else
	(
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", generalInfo.FullName);
		htmlContent := htmlContent.Replace("{{CompanyShortName}}", generalInfo.ShortName);
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", + generalInfo.CompanyCity + ", " + generalInfo.CompanyAddress );
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", generalInfo.OrganizationNumber);
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", generalInfo.TaxNumber);
		htmlContent := htmlContent.Replace("{{ActivityNumber}}", generalInfo.ActivityNumber);
		htmlContent := htmlContent.Replace("{{OtherCompanyActivitiesYesNo}}", generalInfo.OtherCompanyActivities != "" ? "DA" : "NE");
		
		if(generalInfo.LegalRepresentatives != null and generalInfo.LegalRepresentatives.Length > 0) then
		(
			htmlContent := htmlContent.Replace("{{LegalRepresentativeFullName}}", generalInfo.LegalRepresentatives[0].FullName);
			htmlContent := htmlContent.Replace("{{LegalRepresentativeDateOfBirth}}", generalInfo.LegalRepresentatives[0].DateOfBirthStr);
			htmlContent := htmlContent.Replace("{{LegalRepresentativePlaceOfBirth}}", generalInfo.LegalRepresentatives[0].PlaceOfBirth);
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
		
		htmlContent := htmlContent.Replace("{{CompanyContactPerson}}", businessData.EComerceContactFullName);
		htmlContent := htmlContent.Replace("{{CompanyTelephone}}", businessData.EComerceResponsiblePersonPhone);
		htmlContent := htmlContent.Replace("{{CompanyEmail}}", businessData.EComerceContactEmail);
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
			htmlContent := htmlContent.Replace("{{ExpectedMonthlyTurnover}}", Str(businessData.ExpectedMonthlyTurnover) + " RSD");
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
		
		if(companyStructure.OwnerStructure != POWRS.PaymentLink.Onboarding.Enums.OwnerStructure.Person and 
			companyStructure.Owners != null and 
			companyStructure.Owners.Length > 0
		) then 
		(
			htmlContent := htmlContent.Replace("{{ShowOwners}}", "showDiv");
			ownerStructureTable := Create(System.Text.StringBuilder);
			
			foreach (item in companyStructure.Owners) do(
				ownerStructureTable.Append("<tr>");
				ownerStructureTable.Append("<td>" + item.FullName + "</td>");
				ownerStructureTable.Append("<td>" + item.AddressOfResidence + ", " + item.CityOfResidence + "</td>");
				ownerStructureTable.Append("<td>" + item.DateOfBirthStr + "</td>");
				ownerStructureTable.Append("<td>" + item.Citizenship + "</td>");
				ownerStructureTable.Append("<td>" + item.OwningPercentage + "</td>");
				ownerStructureTable.Append("<td>" + item.Role + "</td>");
				ownerStructureTable.Append("</tr>");
			);
			
			htmlContent := htmlContent.Replace("{{OwnerStructureTable}}", ownerStructureTable.ToString());
			destroy(ownerStructureTable);
		)
		else 
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
				legalRepresentativesStr +=  generalInfo.LegalRepresentatives[i].FullName + (i != generalInfo.LegalRepresentatives.Length - 1 ? ", " : "");
			);
		
			htmlContent := htmlContent.Replace("{{ShowLegalRepresentatives}}", "showDiv");
			htmlContent := htmlContent.Replace("{{LegalRepresentativesStr}}", legalRepresentativesStr);
		)else 
		(
			htmlContent := htmlContent.Replace("{{ShowLegalRepresentatives}}", "hideDiv");
			htmlContent := htmlContent.Replace("{{LegalRepresentativesStr}}", "");
		);
		
		htmlContent := htmlContent.Replace("{{chBoxInternetPlatforma}}", (generalInfo.CompanyWebsite != "" ? "checked" : ""));
		htmlContent := htmlContent.Replace("{{chBoxInternetProdajnoMesto}}", (generalInfo.CompanyWebshop != "" ? "checked" : ""));
		htmlContent := htmlContent.Replace("{{EComerceContactFullName}}", businessData.EComerceContactFullName);
		htmlContent := htmlContent.Replace("{{EComerceResponsiblePersonPhone}}", businessData.EComerceResponsiblePersonPhone);
		htmlContent := htmlContent.Replace("{{EComerceContactEmail}}", businessData.EComerceContactEmail);
		htmlContent := htmlContent.Replace("{{CompanyWebshop}}", generalInfo.CompanyWebshop);
		htmlContent := htmlContent.Replace("{{RetailersNumber}}", Str(businessData.RetailersNumber));
		htmlContent := htmlContent.Replace("{{PercentageOfForeignUsers}}", Str(companyStructure.PercentageOfForeignUsers) + " %");
		htmlContent := htmlContent.Replace("{{AverageTransactionAmount}}", Str(businessData.AverageTransactionAmount) + " RSD");
		htmlContent := htmlContent.Replace("{{AverageDailyTurnover}}", Str(businessData.AverageDailyTurnover) + " RSD");
		htmlContent := htmlContent.Replace("{{ThreeMonthAccountTurnover}}", Str(businessData.ThreeMonthAccountTurnover) + " RSD");
		htmlContent := htmlContent.Replace("{{CardPaymentPercentage}}", Str(businessData.CardPaymentPercentage) + " %");
		htmlContent := htmlContent.Replace("{{DescriptionOfTheGoodsToBeSoldOnline}}", businessData.DescriptionOfTheGoodsToBeSoldOnline);
		htmlContent := htmlContent.Replace("{{MethodOfDeliveringGoodsToCustomers}}", businessData.MethodOfDeliveringGoodsToCustomers);
		htmlContent := htmlContent.Replace("{{ExpectedYearlyTurnover}}", Str(businessData.ExpectedYearlyTurnover) + " RSD");
		htmlContent := htmlContent.Replace("{{CheapestProductAmount}}", Str(businessData.CheapestProductAmount) + " RSD");
		htmlContent := htmlContent.Replace("{{MostExpensiveProductAmount}}", Str(businessData.MostExpensiveProductAmount) + " RSD");
		htmlContent := htmlContent.Replace("{{SellingGoodsWithDelayedDelivery}}", (businessData.SellingGoodsWithDelayedDelivery ? "Da" : "Ne"));
		htmlContent := htmlContent.Replace("{{PeriodFromPaymentToDeliveryInDays}}", Str(businessData.PeriodFromPaymentToDeliveryInDays));
		htmlContent := htmlContent.Replace("{{DoYouHaveCustomerComplaints}}", (businessData.ComplaintsPerMonth > 0 ? "Da" : "Ne"));
		htmlContent := htmlContent.Replace("{{ComplaintsPerMonth}}", Str(businessData.ComplaintsPerMonth));
		htmlContent := htmlContent.Replace("{{ComplaintsPerYear}}", Str(businessData.ComplaintsPerYear));
		htmlContent := htmlContent.Replace("{{BusinessModel}}", businessData.BusinessModel);
		
		if(generalInfo.LegalRepresentatives.Length > 1) then
		(
			htmlContent := htmlContent.Replace("{{showHideOtherLegalRepresentatives}}", "showDiv");
			htmlContent := htmlContent.Replace("{{pagebreak}}", "pagebreak");
		
			otherLegalRepresentativesTable := Create(System.Text.StringBuilder);
			FOR i := 1 TO generalInfo.LegalRepresentatives.Length - 1 STEP 1 DO
			(
				otherLegalRepresentativesTable.Append("<br />");
				otherLegalRepresentativesTable.Append("<div>" + Str(i) + "</div>");
				otherLegalRepresentativesTable.Append("<table class=\"tbl2\">");
				otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Ime i prezime zastupnika</td><td>" + generalInfo.LegalRepresentatives[i].FullName + "</td></tr>");
				otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Datum i mesto rođenja</td><td>" + generalInfo.LegalRepresentatives[i].DateOfBirthStr + ", " + generalInfo.LegalRepresentatives[i].PlaceOfBirth + "</td></tr>");
				otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Vrsta ličnog dokumenta i broj</td><td>" + (generalInfo.LegalRepresentatives[i].DocumentType == POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard ? "Lična karta" : "Pasoš") + ", " + generalInfo.LegalRepresentatives[i].DocumentNumber + "</td></tr>");
				otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Datum i mesto izdavanja ličnog dokumenta</td><td>" + generalInfo.LegalRepresentatives[i].DateOfIssueStr + ", " + generalInfo.LegalRepresentatives[i].PlaceOfIssue + "</td></tr>");
				otherLegalRepresentativesTable.Append("<tr><td class=\"tbl2_colLabel_td\">Boravište/Prebivalište</td><td>" + generalInfo.LegalRepresentatives[i].AddressOfResidence + ", " + generalInfo.LegalRepresentatives[i].CityOfResidence + "</td></tr>");
				otherLegalRepresentativesTable.Append("</table>");
				otherLegalRepresentativesTable.Append("<br />");
			);
			htmlContent := htmlContent.Replace("{{OtherLegalRepresentativesTable}}", otherLegalRepresentativesTable.ToString());
		)
		else
		(
			htmlContent := htmlContent.Replace("{{showHideOtherLegalRepresentatives}}", "hideDiv");
			htmlContent := htmlContent.Replace("{{pagebreak}}", "");
			htmlContent := htmlContent.Replace("{{OtherLegalRepresentativesTable}}", "");
		);
		
		destroy(otherLegalRepresentativesTable);
	);

	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Return (newPDFFilePath);
);

DownloadTemplateContractWithEMI(PIsEmptyFile) := (
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	if(generalInfo == null)then
	(
		Error("GeneralCompanyInformation must be populated");
	);
	if(generalInfo.LegalRepresentatives == null or generalInfo.LegalRepresentatives.Length == 0)then
	(
		Error("LegalRepresentatives must be populated");
	);
	businessData:= select top 1 * from POWRS.PaymentLink.Onboarding.BusinessData where UserName = SessionUser.username;

	newPDFFilePath := "";
	
	templateFileName := "ContractPaySpot";
	newFileName := "New_ContractPaySpot";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!System.IO.File.Exists(htmlTemplatePath)) then
	(
		Error("File does not exist");
	);
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
		
	clientTypeStr := POWRS.PaymentLink.ClientType.OrgClientType.GetClientTypeByUserName(SessionUser.username).ToString();
	
	fileAttachment1Path := fileRootPath + "\\Attachment1\\" + clientTypeStr + "\\Attachment1.html";
	if (!System.IO.File.Exists(fileAttachment1Path)) then
	(
		Error("File Attachment1 does not exist");
	);
	attachmentHtmlContent := System.IO.File.ReadAllText(fileAttachment1Path);
	htmlContent := htmlContent.Replace("{{Attachment1}}", attachmentHtmlContent);
	
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
		
		if(System.String.IsNullOrWhiteSpace(generalInfo.FullName))then(
			errors.Add("GeneralCompanyInformation.FullName");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.CompanyAddress))then(
			errors.Add("GeneralCompanyInformation.CompanyAddress");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.CompanyCity))then(
			errors.Add("GeneralCompanyInformation.CompanyCity");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.OrganizationNumber))then(
			errors.Add("GeneralCompanyInformation.OrganizationNumber");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.TaxNumber))then(
			errors.Add("GeneralCompanyInformation.TaxNumber");
		);
		if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[0].FullName))then(
			errors.Add("GeneralCompanyInformation.LegalRepresentatives;0.FullName");
		);
		
		if(errors.Count > 0)then
		(
			Error(errors);
			return (0);
		);
	
		htmlContent := htmlContent.Replace("{{CompanyFullName}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyAddress}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.CompanyAddress + " " + generalInfo.CompanyCity + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyOrganizationNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.OrganizationNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyTaxNumber}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.TaxNumber + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{CompanyRepresenter}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + generalInfo.LegalRepresentatives[0].FullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{EmailAdresaTrgovac}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + businessData.EComerceContactEmail + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{KontaktOsobaTrgovac}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + businessData.EComerceContactFullName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		htmlContent := htmlContent.Replace("{{TelefonTrgovac}}", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + businessData.EComerceResponsiblePersonPhone + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
	);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Return (newPDFFilePath);
);

DownloadTemplateStatementOfOfficialDocument(PIsEmptyFile, PPersonPositionInCompany, PPersonIndex) := (
	newPDFFilePath := "";
	
	templateFileName := "StatementOfOfficialDocument";
	newFileName := "New_StatementOfOfficialDocument";
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\" + templateFileName + ".html"; 
	if (!System.IO.File.Exists(htmlTemplatePath)) then
	(
		Error("File does not exist");
	);
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	if(PIsEmptyFile)then
	(
		htmlContent := htmlContent.Replace("{{ClientFullName}}", "");
		htmlContent := htmlContent.Replace("{{PersonalNumber}}", "");
		htmlContent := htmlContent.Replace("{{DateAndPlaceOfBirth}}", "");
		htmlContent := htmlContent.Replace("{{AddressOfResidence}}", "");
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
			
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].FullName))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".FullName");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].PersonalNumber))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".PersonalNumber");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].DateOfBirthStr))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".DateOfBirthStr");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].PlaceOfBirth))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".PlaceOfBirth");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].AddressOfResidence))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".AddressOfResidence");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].CityOfResidence))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".CityOfResidence");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].DateOfIssueStr))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".DateOfIssueStr");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].PlaceOfIssue))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".PlaceOfIssue");
			);
			if(System.String.IsNullOrWhiteSpace(generalInfo.LegalRepresentatives[PPersonIndex].IssuerName))then(
				errors.Add("GeneralCompanyInformation.LegalRepresentatives;" + PPersonIndex +".IssuerName");
			);
			
			if(errors.Count > 0)then
			(
				Error(errors);
				return (0);
			);
			
			htmlContent := htmlContent.Replace("{{ClientFullName}}", generalInfo.LegalRepresentatives[PPersonIndex].FullName);
			htmlContent := htmlContent.Replace("{{PersonalNumber}}", generalInfo.LegalRepresentatives[PPersonIndex].PersonalNumber);
			htmlContent := htmlContent.Replace("{{DateAndPlaceOfBirth}}", generalInfo.LegalRepresentatives[PPersonIndex].DateOfBirthStr + ", " + generalInfo.LegalRepresentatives[PPersonIndex].PlaceOfBirth);
			htmlContent := htmlContent.Replace("{{AddressOfResidence}}", generalInfo.LegalRepresentatives[PPersonIndex].AddressOfResidence);
			htmlContent := htmlContent.Replace("{{CityOdResidence}}", generalInfo.LegalRepresentatives[PPersonIndex].CityOfResidence);
			htmlContent := htmlContent.Replace("{{DocumentTypeAndNumber}}", (generalInfo.LegalRepresentatives[PPersonIndex].DocumentType == POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard ? "Lična karta" : "Pasoš") + ", " + generalInfo.LegalRepresentatives[PPersonIndex].DocumentNumber);
			htmlContent := htmlContent.Replace("{{DocumentIssueDate}}", generalInfo.LegalRepresentatives[PPersonIndex].DateOfIssueStr + ", " + generalInfo.LegalRepresentatives[PPersonIndex].PlaceOfIssue);
			htmlContent := htmlContent.Replace("{{DocumentIssuerName}}", generalInfo.LegalRepresentatives[PPersonIndex].IssuerName);
			
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
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "checked");
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
			
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].FullName))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".FullName");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].PersonalNumber))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".PersonalNumber");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].DateOfBirthStr))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".DateOfBirthStr");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].PlaceOfBirth))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".PlaceOfBirth");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].AddressOfResidence))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".AddressOfResidence");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].CityOfResidence))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".CityOfResidence");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].IssueDateStr))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".IssueDateStr");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].DocumentIssuancePlace))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".DocumentIssuancePlace");
			);
			if(System.String.IsNullOrWhiteSpace(companyStructure.Owners[PPersonIndex].IssuerName))then(
				errors.Add("CompanyStructure.Owners;" + PPersonIndex +".IssuerName");
			);
			
			if(errors.Count > 0)then
			(
				Error(errors);
				return (0);
			);
		
			htmlContent := htmlContent.Replace("{{ClientFullName}}", companyStructure.Owners[PPersonIndex].FullName);
			htmlContent := htmlContent.Replace("{{PersonalNumber}}", companyStructure.Owners[PPersonIndex].PersonalNumber);
			htmlContent := htmlContent.Replace("{{DateAndPlaceOfBirth}}", companyStructure.Owners[PPersonIndex].DateOfBirthStr + ", " + companyStructure.Owners[PPersonIndex].PlaceOfBirth);
			htmlContent := htmlContent.Replace("{{AddressOfResidence}}", companyStructure.Owners[PPersonIndex].AddressOfResidence);
			htmlContent := htmlContent.Replace("{{CityOdResidence}}", companyStructure.Owners[PPersonIndex].CityOfResidence);
			htmlContent := htmlContent.Replace("{{DocumentTypeAndNumber}}", (companyStructure.Owners[PPersonIndex].DocumentType == POWRS.PaymentLink.Onboarding.Enums.DocumentType.IDCard ? "Lična karta" : "Pasoš") + ", " + companyStructure.Owners[PPersonIndex].DocumentNumber);
			htmlContent := htmlContent.Replace("{{DocumentIssueDate}}", companyStructure.Owners[PPersonIndex].IssueDateStr + ", " + companyStructure.Owners[PPersonIndex].DocumentIssuancePlace);
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
				htmlContent := htmlContent.Replace("{{IsPoliticallyExposedPerson_No}}", "checked");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_Yes}}", "");
				htmlContent := htmlContent.Replace("{{IsForeignPoliticallyExposedPerson_No}}", "checked");
			);
		);
	);
	
	newPDFFilePath := CreatePDFFile(fileRootPath, newFileName, htmlContent);
	Return (newPDFFilePath);
);

CreatePDFFile(fileRootPath, newFileName, htmlContent) := (
	newHtmlPath:= fileRootPath + "\\" + newFileName + ".html";
	System.IO.File.WriteAllText(newHtmlPath, htmlContent, System.Text.Encoding.UTF8);
	newPDFFilePath:= fileRootPath + "\\" + newFileName + ".pdf";
	
	ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
		"--allow \"" + fileRootPath + "\""
		+ " \"" + newHtmlPath + "\"" 
		+ " \"" +  newPDFFilePath + "\""
		, fileRootPath);
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
		returnFilePath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PromissoryNoteInstruction.pdf";
		fileName := "PromissoryNoteIntsruction.pdf";
	);
	
    bytes := System.IO.File.ReadAllBytes(returnFilePath);
	Log.Informational("Succeffully returned file: " + PFileType, logObject, logActor, logEventID, null);
	
	{
		Name: fileName,
		File: bytes
	}
)
catch 
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
