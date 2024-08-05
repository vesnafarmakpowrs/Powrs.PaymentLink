SessionUser:= Global.ValidateAgentApiToken(false, false);

({
	"t_calc_Header": Required(Str(Pt_calc_Header)),
	"t_calc_Now_Title": Required(Str(Pt_calc_Now_Title)),
	"t_calc_Forecast_Title": Required(Str(Pt_calc_Forecast_Title)),
	
	"t_calc_CurrentData_TotalRevenue": Required(Str(Pt_calc_CurrentData_TotalRevenue)),
	"t_calc_CurrentData_AvgAmountPerTrn": Required(Str(Pt_calc_CurrentData_AvgAmountPerTrn)),
	"t_calc_CurrentData_TotalTrn": Required(Str(Pt_calc_CurrentData_TotalTrn)),
	"t_calc_CurrentData_CardTrnPercentage": Required(Str(Pt_calc_CurrentData_CardTrnPercentage)),
	"t_calc_CurrentData_CardFee": Required(Str(Pt_calc_CurrentData_CardFee)),
	"t_calc_CurrentData_TotalCardPercentage_lbl": Required(Str(Pt_calc_CurrentData_TotalCardPercentage_lbl)),
	"t_calc_CurrentData_TotalCardCost_lbl": Required(Str(Pt_calc_CurrentData_TotalCardCost_lbl)),
	
	"t_calc_Card_Title": Required(Str(Pt_calc_Card_Title)),
    "t_calc_Card_TrnPercentage": Required(Str(Pt_calc_Card_TrnPercentage)),
    "t_calc_Card_NumberOfTrn": Required(Str(Pt_calc_Card_NumberOfTrn)),
    "t_calc_Card_AvgAmountPerTrn": Required(Str(Pt_calc_Card_AvgAmountPerTrn)),
    "t_calc_Card_VaulterFee": Required(Str(Pt_calc_Card_VaulterFee)),
    "t_calc_Card_VaulterCost_lbl": Required(Str(Pt_calc_Card_VaulterCost_lbl)),
    "t_calc_Card_Saved_lbl": Required(Str(Pt_calc_Card_Saved_lbl)),
	
	"t_calc_A2A_Title": Required(Str(Pt_calc_A2A_Title)),
    "t_calc_A2A_TrnPercentage": Required(Str(Pt_calc_A2A_TrnPercentage)),
    "t_calc_A2A_NumberOfTrn": Required(Str(Pt_calc_A2A_NumberOfTrn)),
    "t_calc_A2A_AvgAmountPerTrn": Required(Str(Pt_calc_A2A_AvgAmountPerTrn)),
    "t_calc_A2A_VaulterFee": Required(Str(Pt_calc_A2A_VaulterFee)),
    "t_calc_A2A_VaulterCost_lbl": Required(Str(Pt_calc_A2A_VaulterCost_lbl)),
    "t_calc_A2A_Saved_lbl": Required(Str(Pt_calc_A2A_Saved_lbl)),
	
	"t_calc_Holding_Title": Required(Str(Pt_calc_Holding_Title)),
    "t_calc_Holding_TrnPercentage": Required(Str(Pt_calc_Holding_TrnPercentage)),
    "t_calc_Holding_NumberOfTrn": Required(Str(Pt_calc_Holding_NumberOfTrn)),
    "t_calc_Holding_HoldingFee": Required(Str(Pt_calc_Holding_HoldingFee)),
    "t_calc_Holding_VaulterCost_lbl": Required(Str(Pt_calc_Holding_VaulterCost_lbl)),
    "t_calc_Holding_WhoWillPayCost_Title": Required(Str(Pt_calc_Holding_WhoWillPayCost_Title)),
    "t_calc_Holding_Buyer_lbl": Required(Str(Pt_calc_Holding_Buyer_lbl)),
    "t_calc_Holding_Seller_lbl": Required(Str(Pt_calc_Holding_Seller_lbl)),
    "t_calc_Holding_KickBackDiscount_Title": Required(Str(Pt_calc_Holding_KickBackDiscount_Title)),
    "t_calc_Holding_KickBackPerTrn": Required(Str(Pt_calc_Holding_KickBackPerTrn)),
    "t_calc_Holding_IncomeSummary_lbl": Required(Str(Pt_calc_Holding_IncomeSummary_lbl)),
	
	"t_calc_Summary_Title": Required(Str(Pt_calc_Summary_Title)),
	"t_calc_Saved_lbl": Required(Str(Pt_calc_Saved_lbl)),
	"t_calc_KickBackDiscount_lbl": Required(Str(Pt_calc_KickBackDiscount_lbl)),
	
	"t_calc_Note": Required(Str(Pt_calc_Note)),
		
	"t_calc_tblHeaderTotalTrn": Required(Str(Pt_calc_tblHeaderTotalTrn)),
	"t_calc_tblData_CardTrn": Required(Str(Pt_calc_tblData_CardTrn)),
	"t_calc_tblData_A2ATrn": Required(Str(Pt_calc_tblData_A2ATrn)),
	"t_calc_tblHeaderHolding": Required(Str(Pt_calc_tblHeaderHolding)),
	"t_calc_tblData_HoldingTrn": Required(Str(Pt_calc_tblData_HoldingTrn)),
    	
	"organizationNumber": Required(Str(PorganizationNumber)),
	"sendToEmail": Required(Bool(PsendToEmail)),
	"email": Optional(Str(Pemail))
}:= Posted) ??? BadRequest(Exception.Message);

logObjectID := SessionUser.username;
logEventID := "GenerateFormPDF.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(	
	if(PsendToEmail and System.String.IsNullOrWhiteSpace(Pemail))then
	(
		Error("Recipient email must be populated...");
	);

	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\FeeCalculator\\HtmlTemplates\\FeeCalculatorForm";
	htmlTemplatePath := fileRootPath + "\\FeeCalc.html"; 
	if (!File.Exists(htmlTemplatePath)) then
	(
		Error("Template file does not exist");
	);

	feeCalcObj := select top 1 * from POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator where OrganizationNumber = PorganizationNumber;
	if(feeCalcObj == null) then 
	(
		Error("OrganizationNumber don't exists in db");
	);
	
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	htmlContent := htmlContent.Replace("{{t_calc_Header}}", Pt_calc_Header);
	htmlContent := htmlContent.Replace("{{t_calc_Now_Title}}", Pt_calc_Now_Title);
	htmlContent := htmlContent.Replace("{{t_calc_Forecast_Title}}", Pt_calc_Forecast_Title);
	
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_TotalRevenue}}", Pt_calc_CurrentData_TotalRevenue);	
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_AvgAmountPerTrn}}", Pt_calc_CurrentData_AvgAmountPerTrn);
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_TotalTrn}}", Pt_calc_CurrentData_TotalTrn);
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_CardTrnPercentage}}", Pt_calc_CurrentData_CardTrnPercentage);
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_CardFee}}", Pt_calc_CurrentData_CardFee);
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_TotalCardPercentage_lbl}}", Pt_calc_CurrentData_TotalCardPercentage_lbl);
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_TotalCardCost_lbl}}", Pt_calc_CurrentData_TotalCardCost_lbl);
	
	htmlContent := htmlContent.Replace("{{CurrentData_TotalRevenue}}", Str(feeCalcObj.CurrentData.TotalRevenue));
	htmlContent := htmlContent.Replace("{{CurrentData_AvgAmountPerTrn}}", Str(feeCalcObj.CurrentData.AverageAmount));
	htmlContent := htmlContent.Replace("{{CurrentData_TotalTrn}}", Str(feeCalcObj.CurrentData.TotalTransactions));
	htmlContent := htmlContent.Replace("{{CurrentData_CardTrnPercentage}}", Str(feeCalcObj.CurrentData.CardTransactionPercentage));
	htmlContent := htmlContent.Replace("{{CurrentData_CardFee}}", Str(feeCalcObj.CurrentData.CardFee));
	htmlContent := htmlContent.Replace("{{CurrentData_TotalCardPercentage_lbl}}", Str(feeCalcObj.CurrentData.TotalCardTransactions));
	htmlContent := htmlContent.Replace("{{CurrentData_TotalCardCost_lbl}}", Str(feeCalcObj.CurrentData.TotalCardCost));
		
	
	if(feeCalcObj.CardData.ShowGroup) then (
		htmlContent := htmlContent.Replace("{{t_calc_Card_Title}}", Pt_calc_Card_Title);
		htmlContent := htmlContent.Replace("{{t_calc_Card_TrnPercentage}}", Pt_calc_Card_TrnPercentage);
		htmlContent := htmlContent.Replace("{{t_calc_Card_NumberOfTrn}}", Pt_calc_Card_NumberOfTrn);
		htmlContent := htmlContent.Replace("{{t_calc_Card_AvgAmountPerTrn}}", Pt_calc_Card_AvgAmountPerTrn);
		htmlContent := htmlContent.Replace("{{t_calc_Card_VaulterFee}}", Pt_calc_Card_VaulterFee);
		htmlContent := htmlContent.Replace("{{t_calc_Card_VaulterCost_lbl}}", Pt_calc_Card_VaulterCost_lbl);
		htmlContent := htmlContent.Replace("{{t_calc_Card_Saved_lbl}}", Pt_calc_Card_Saved_lbl);
		
		htmlContent := htmlContent.Replace("{{Card_TrnPercentage}}", Str(feeCalcObj.CardData.TransactionPercentage));
		htmlContent := htmlContent.Replace("{{Card_NumberOfTrn}}", Str(feeCalcObj.CardData.NumberOfTransactions));
		htmlContent := htmlContent.Replace("{{Card_AvgAmountPerTrn}}", Str(feeCalcObj.CardData.AverageAmount));
		htmlContent := htmlContent.Replace("{{Card_VaulterFee}}", Str(feeCalcObj.CardData.Fee));
		htmlContent := htmlContent.Replace("{{Card_VaulterCost_lbl}}", Str(feeCalcObj.CardData.Cost));
		htmlContent := htmlContent.Replace("{{Card_Saved_lbl}}", Str(feeCalcObj.CardData.Saved));
	) else (
		htmlContent := htmlContent.Replace("{{Card_hideDiv}}", "hideDiv");
	);
	
	if(feeCalcObj.A2AData.ShowGroup) then (
		htmlContent := htmlContent.Replace("{{t_calc_A2A_Title}}", Pt_calc_A2A_Title);
		htmlContent := htmlContent.Replace("{{t_calc_A2A_TrnPercentage}}", Pt_calc_A2A_TrnPercentage);
		htmlContent := htmlContent.Replace("{{t_calc_A2A_NumberOfTrn}}", Pt_calc_A2A_NumberOfTrn);
		htmlContent := htmlContent.Replace("{{t_calc_A2A_AvgAmountPerTrn}}", Pt_calc_A2A_AvgAmountPerTrn);
		htmlContent := htmlContent.Replace("{{t_calc_A2A_VaulterFee}}", Pt_calc_A2A_VaulterFee);
		htmlContent := htmlContent.Replace("{{t_calc_A2A_VaulterCost_lbl}}", Pt_calc_A2A_VaulterCost_lbl);
		htmlContent := htmlContent.Replace("{{t_calc_A2A_Saved_lbl}}", Pt_calc_A2A_Saved_lbl);
		
		htmlContent := htmlContent.Replace("{{A2A_TrnPercentage}}", Str(feeCalcObj.A2AData.TransactionPercentage));
		htmlContent := htmlContent.Replace("{{A2A_NumberOfTrn}}", Str(feeCalcObj.A2AData.NumberOfTransactions));
		htmlContent := htmlContent.Replace("{{A2A_AvgAmountPerTrn}}", Str(feeCalcObj.A2AData.AverageAmount));
		htmlContent := htmlContent.Replace("{{A2A_VaulterFee}}", Str(feeCalcObj.A2AData.Fee));
		htmlContent := htmlContent.Replace("{{A2A_VaulterCost_lbl}}", Str(feeCalcObj.A2AData.Cost));
		htmlContent := htmlContent.Replace("{{A2A_Saved_lbl}}", Str(feeCalcObj.A2AData.Saved));
	) else (
		htmlContent := htmlContent.Replace("{{A2A_hideDiv}}", "hideDiv");
	);
	
	if(feeCalcObj.HoldingServiceData.ShowGroup) then (
		htmlContent := htmlContent.Replace("{{t_calc_Holding_Title}}", Pt_calc_Holding_Title);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_TrnPercentage}}", Pt_calc_Holding_TrnPercentage);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_NumberOfTrn}}", Pt_calc_Holding_NumberOfTrn);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_HoldingFee}}", Pt_calc_Holding_HoldingFee);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_HoldingFee}}", Pt_calc_Holding_HoldingFee);		
		htmlContent := htmlContent.Replace("{{t_calc_Holding_VaulterCost_lbl}}", Pt_calc_Holding_VaulterCost_lbl);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_WhoWillPayCost_Title}}", Pt_calc_Holding_WhoWillPayCost_Title);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_Buyer_lbl}}", Pt_calc_Holding_Buyer_lbl);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_Seller_lbl}}", Pt_calc_Holding_Seller_lbl);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_KickBackDiscount_Title}}", Pt_calc_Holding_KickBackDiscount_Title);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_KickBackPerTrn}}", Pt_calc_Holding_KickBackPerTrn);
		htmlContent := htmlContent.Replace("{{t_calc_Holding_IncomeSummary_lbl}}", Pt_calc_Holding_IncomeSummary_lbl);
	
		htmlContent := htmlContent.Replace("{{Holding_TrnPercentage}}", Str(feeCalcObj.HoldingServiceData.TransactionPercentage));
		htmlContent := htmlContent.Replace("{{Holding_NumberOfTrn}}", Str(feeCalcObj.HoldingServiceData.NumberOfTransactions));
		htmlContent := htmlContent.Replace("{{Holding_HoldingFee}}", Str(feeCalcObj.HoldingServiceData.Fee));
		htmlContent := htmlContent.Replace("{{Holding_VaulterCost_lbl}}", Str(feeCalcObj.HoldingServiceData.Cost));
		
		if(feeCalcObj.HoldingServiceData.CostPay == POWRS.PaymentLink.FeeCalculator.Enums.CostPay.Buyer) then
		(
			htmlContent := htmlContent.Replace("{{checked_Buyer}}", "checked='cheked'");
			htmlContent := htmlContent.Replace("{{checked_Seller}}", "");
		) 
		else 
		(
			htmlContent := htmlContent.Replace("{{checked_Buyer}}", "");
			htmlContent := htmlContent.Replace("{{checked_Seller}}", "checked='cheked'");
		);
		
		htmlContent := htmlContent.Replace("{{Holding_KickBackPerTrn}}", Str(feeCalcObj.HoldingServiceData.KickBackPerTransaction));
		htmlContent := htmlContent.Replace("{{Holding_IncomeSummary_lbl}}", Str(feeCalcObj.HoldingServiceData.IncomeSummary));
	) else (
		htmlContent := htmlContent.Replace("{{HoldingService_hideDiv}}", "hideDiv");
	);
	
	htmlContent := htmlContent.Replace("{{t_calc_Summary_Title}}", Pt_calc_Summary_Title);
	htmlContent := htmlContent.Replace("{{t_calc_Saved_lbl}}", Pt_calc_Saved_lbl);
	htmlContent := htmlContent.Replace("{{t_calc_KickBackDiscount_lbl}}", Pt_calc_KickBackDiscount_lbl);
	
	htmlContent := htmlContent.Replace("{{Saved_lbl}}", Str(feeCalcObj.TotalSaved));
	htmlContent := htmlContent.Replace("{{KickBackDiscount_lbl}}", Str(feeCalcObj.KickBack_Discount));
	
	htmlContent := htmlContent.Replace("{{t_calc_Note}}", Pt_calc_Note);
	htmlContent := htmlContent.Replace("{{txtNote}}", "feeCalcObj.Note");
	
	htmlContent := htmlContent.Replace("{{t_calc_tblHeaderTotalTrn}}", Pt_calc_tblHeaderTotalTrn);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_CardTrn}}", Pt_calc_tblData_CardTrn);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_A2ATrn}}", Pt_calc_tblData_A2ATrn);
	htmlContent := htmlContent.Replace("{{t_calc_tblHeaderHolding}}", Pt_calc_tblHeaderHolding);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_HoldingTrn}}", Pt_calc_tblData_HoldingTrn);
	
	htmlContent := htmlContent.Replace("{{currency}}", feeCalcObj.Currency);
	
		
	fileName := "NewFile";
	newHtmlPath:= fileRootPath + "\\" + fileName + ".html";
	System.IO.File.WriteAllText(newHtmlPath, htmlContent, System.Text.Encoding.UTF8);
	pdfPath:= fileRootPath + "\\" + fileName + ".pdf";
	
	ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
		"--allow \"" + fileRootPath + "\""
		+ " \"" + newHtmlPath + "\"" 
		+ " \"" +  pdfPath + "\""
		, fileRootPath);
	
	Log.Informational("Succeffully created pdf:" + fileName + ".pdf", logObjectID, logActor, logEventID, null);
    bytes := System.IO.File.ReadAllBytes(pdfPath);
	
	if(PsendToEmail)then
	(
		MailBody := Create(System.Text.StringBuilder);
		MailBody.Append("Hello,");
		MailBody.Append("<br />");
		MailBody.Append("<br />In mail attachment is you Vaulter calculation.");
		MailBody.Append("<br />");
		MailBody.Append("<br />***");
		MailBody.Append("<br />");
		MailBody.Append("<br />Zdravo,");
		MailBody.Append("<br />");
		MailBody.Append("<br />U prilogu maila ti dostavljamo Vaulter troškovni proračun.");
		MailBody.Append("<br />");
		MailBody.Append("<br />");
		MailBody.Append("<br /><i>Best regards / Srdačan pozdrav");
		MailBody.Append("<br />Vaulter</i>");
	
		ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
		Config := ConfigClass.Instance;
		
		bytesStr := Base64Encode(bytes);
		
		POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, Pemail, "Vaulter Calculation", Str(MailBody), bytesStr, "Vaulter calculation.pdf");
		
		destroy(MailBody);
		
		{
			success: true
		}
	)
	else
	(
		{
			Name: fileName + ".pdf",
			PDF: bytes
		}
	);
	
) 
catch
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);