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
    "t_calc_Holding_VaulterCost_lbl": Required(Str(Pt_calc_Holding_VaulterCost)),
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
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\FeeCalculator\\HtmlTemplates\\FeeCalculatorForm";
	htmlTemplatePath := fileRootPath + "\\FeeCalc.html"; 
	if (!File.Exists(htmlTemplatePath)) then
	(
		Error("Template file does not exist");
	);

	feeCalcObj := select top 1 * from POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator where OrganizationNumber = POrganizationNumber;
	if(feeCalcObj == null) then 
	(
		Error("OrganizationNumber don't exists in db");
	);
	
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	htmlContent := htmlContent.Replace("{{t_calc_Header}}", Pt_calc_Header);
	htmlContent := htmlContent.Replace("{{t_calc_CurrentData_Title}}", Pt_calc_Customer);
	htmlContent := htmlContent.Replace("{{t_calc_CustomerID}}", Pt_calc_CustomerID);
	htmlContent := htmlContent.Replace("{{t_calc_TotalRevenue}}", Pt_calc_TotalRevenue);	
	htmlContent := htmlContent.Replace("{{t_calc_Note}}", Pt_calc_Note);
	htmlContent := htmlContent.Replace("{{txtCustomer}}", PtxtCustomer);
	htmlContent := htmlContent.Replace("{{txtCustomerID}}", PtxtCustomerID);
	htmlContent := htmlContent.Replace("{{txtTotalRevenue}}", PtxtTotalRevenue);
	htmlContent := htmlContent.Replace("{{txtNote}}", PtxtNote);
	
	if(PchbxShowCard) then (
		htmlContent := htmlContent.Replace("{{t_calc_CARD}}", Pt_calc_CARD);
		htmlContent := htmlContent.Replace("{{t_calc_NumberOfTrx_Card}}", Pt_calc_NumberOfTrx_Card);
		htmlContent := htmlContent.Replace("{{t_calc_AverAmountPerTrx_Card}}", Pt_calc_AverAmountPerTrx_Card);
		htmlContent := htmlContent.Replace("{{t_calc_CardFee_Card}}", Pt_calc_CardFee_Card);
		htmlContent := htmlContent.Replace("{{t_calc_totalCost_card}}", Pt_calc_totalCost_card);
		htmlContent := htmlContent.Replace("{{t_calc_VaulterCardFee_Card}}", Pt_calc_VaulterCardFee_Card);
		htmlContent := htmlContent.Replace("{{t_calc_totalVaulterCost_card}}", Pt_calc_totalVaulterCost_card);
		htmlContent := htmlContent.Replace("{{t_calc_SAVED_card}}", Pt_calc_SAVED_card);
		htmlContent := htmlContent.Replace("{{t_calc_BUSINESS_card}}", Pt_calc_BUSINESS_card);
	
		htmlContent := htmlContent.Replace("{{txtNumberOfTrx_Card}}", PtxtNumberOfTrx_Card);
		htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_Card}}", PtxtAverAmountPerTrx_Card);
		htmlContent := htmlContent.Replace("{{txtCardFee_Card}}", PtxtCardFee_Card);
		htmlContent := htmlContent.Replace("{{lblTotalCost_Card}}", PtotalCost_Card);
		htmlContent := htmlContent.Replace("{{txtVaulterCardFee_Card}}", PtxtVaulterCardFee_Card);
		htmlContent := htmlContent.Replace("{{lblVaulterCost_Card}}", PvaulterCost_Card);
		htmlContent := htmlContent.Replace("{{lblSaved_card}}", Psaved_card);
		htmlContent := htmlContent.Replace("{{lblBusiness_card}}", Pbusiness_card);
	) else (
		htmlContent := htmlContent.Replace("{{Card_hideDiv}}", "hideDiv");
	);
	
	if(PchbxShowA2A) then (
		htmlContent := htmlContent.Replace("{{t_calc_A2A}}", Pt_calc_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_NumberOfTrx_A2A}}", Pt_calc_NumberOfTrx_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_AverAmountPerTrx_A2A}}", Pt_calc_AverAmountPerTrx_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_VaulterA2AFee_A2A}}", Pt_calc_VaulterA2AFee_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_totalVaulterCost_A2A}}", Pt_calc_totalVaulterCost_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_SAVED_A2A}}", Pt_calc_SAVED_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_BUSINESS_A2A}}", Pt_calc_BUSINESS_A2A);
	
		htmlContent := htmlContent.Replace("{{txtNumberOfTrx_A2A}}", PtxtNumberOfTrx_A2A);
		htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_A2A}}", PtxtAverAmountPerTrx_A2A);
		htmlContent := htmlContent.Replace("{{txtVaulterA2AFee_A2A}}", PtxtVaulterA2AFee_A2A);
		htmlContent := htmlContent.Replace("{{lblVaulterCost_A2A}}", PvaulterCost_A2A);
		htmlContent := htmlContent.Replace("{{lblSaved_A2A}}", Psaved_A2A);
		htmlContent := htmlContent.Replace("{{lblBusiness_A2A}}", Pbusiness_A2A);
	) else (
		htmlContent := htmlContent.Replace("{{A2A_hideDiv}}", "hideDiv");
	);
	
	if(PchbxShowCardHolding) then (
		htmlContent := htmlContent.Replace("{{t_calc_CARD_holding}}", Pt_calc_CARD_holding);
		htmlContent := htmlContent.Replace("{{t_calc_NumberOfTrx_CardHolding}}", Pt_calc_NumberOfTrx_CardHolding);
		htmlContent := htmlContent.Replace("{{t_calc_AverAmountPerTrx_CardHolding}}", Pt_calc_AverAmountPerTrx_CardHolding);
		htmlContent := htmlContent.Replace("{{t_calc_VaulterFee_CardHolding}}", Pt_calc_VaulterFee_CardHolding);
		htmlContent := htmlContent.Replace("{{t_calc_totalCost_CardHolding}}", Pt_calc_totalCost_CardHolding);
		htmlContent := htmlContent.Replace("{{t_slider_lblHeader}}", Pt_slider_lblHeader);
		htmlContent := htmlContent.Replace("{{t_slider_lblSeller}}", Pt_slider_lblSeller);
		htmlContent := htmlContent.Replace("{{t_slider_lblBuyer}}", Pt_slider_lblBuyer);
		htmlContent := htmlContent.Replace("{{t_calc_KickBack_card}}", Pt_calc_KickBack_card);
		htmlContent := htmlContent.Replace("{{t_calc_NumberOfTrx_CardHolding_KickBack}}", Pt_calc_NumberOfTrx_CardHolding_KickBack);
		htmlContent := htmlContent.Replace("{{t_calc_VaulterKickBackPerTry_CardHolding_KickBack}}", Pt_calc_VaulterKickBackPerTry_CardHolding_KickBack);
		htmlContent := htmlContent.Replace("{{t_calc_totalIncome_CardHolding_KickBack}}", Pt_calc_totalIncome_CardHolding_KickBack);
	
		htmlContent := htmlContent.Replace("{{txtNumberOfTrx_CardHolding}}", PtxtNumberOfTrx_CardHolding);
		htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_CardHolding}}", PtxtAverAmountPerTrx_CardHolding);
		htmlContent := htmlContent.Replace("{{txtVaulterFee_CardHolding}}", PtxtVaulterFee_CardHolding);
		htmlContent := htmlContent.Replace("{{lblTotalCost_CardHolding}}", PtotalCost_CardHolding);
		htmlContent := htmlContent.Replace("{{sliderSellerBuyer_CardHolding}}", PsliderSellerBuyer_CardHolding);
		htmlContent := htmlContent.Replace("{{txtNumberOfTrx_CardHolding_KickBack}}", PtxtNumberOfTrx_CardHolding_KickBack);
		htmlContent := htmlContent.Replace("{{txtVaulterKickBackPerTry_CardHolding_KickBack}}", PtxtVaulterKickBackPerTry_CardHolding_KickBack);
		htmlContent := htmlContent.Replace("{{lblTotalIncome_CardHolding_KickBack}}", PtotalIncome_CardHolding_KickBack);
	) else (
		htmlContent := htmlContent.Replace("{{CardHolding_hideDiv}}", "hideDiv");
	);
	
	if(PchbxShowA2AHolding) then (
		htmlContent := htmlContent.Replace("{{t_calc_A2A_holding}}", Pt_calc_A2A_holding);
		htmlContent := htmlContent.Replace("{{t_calc_NumberOfTrx_A2AHolding}}", Pt_calc_NumberOfTrx_A2AHolding);
		htmlContent := htmlContent.Replace("{{t_calc_AverAmountPerTrx_A2AHolding}}", Pt_calc_AverAmountPerTrx_A2AHolding);
		htmlContent := htmlContent.Replace("{{t_calc_VaulterFee_A2AHolding}}", Pt_calc_VaulterFee_A2AHolding);
		htmlContent := htmlContent.Replace("{{t_calc_totalCost_A2AHolding}}", Pt_calc_totalCost_A2AHolding);
		htmlContent := htmlContent.Replace("{{t_slider_lblHeader}}", Pt_slider_lblHeader);
		htmlContent := htmlContent.Replace("{{t_slider_lblSeller}}", Pt_slider_lblSeller);
		htmlContent := htmlContent.Replace("{{t_slider_lblBuyer}}", Pt_slider_lblBuyer);
		htmlContent := htmlContent.Replace("{{t_calc_KickBack_A2A}}", Pt_calc_KickBack_A2A);
		htmlContent := htmlContent.Replace("{{t_calc_NumberOfTrx_A2AHolding_KickBack}}", Pt_calc_NumberOfTrx_A2AHolding_KickBack);
		htmlContent := htmlContent.Replace("{{t_calc_VaulterKickBackPerTry_A2AHolding_KickBack}}", Pt_calc_VaulterKickBackPerTry_A2AHolding_KickBack);
		htmlContent := htmlContent.Replace("{{t_calc_totalIncome_A2AHolding_KickBack}}", Pt_calc_totalIncome_A2AHolding_KickBack);
	
	
		htmlContent := htmlContent.Replace("{{txtNumberOfTrx_A2AHolding}}", PtxtNumberOfTrx_A2AHolding);
		htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_A2AHolding}}", PtxtAverAmountPerTrx_A2AHolding);
		htmlContent := htmlContent.Replace("{{txtVaulterFee_A2AHolding}}", PtxtVaulterFee_A2AHolding);
		htmlContent := htmlContent.Replace("{{lblTotalCost_A2AHolding}}", PtotalCost_A2AHolding);
		htmlContent := htmlContent.Replace("{{sliderSellerBuyer_A2AHolding}}", PsliderSellerBuyer_A2AHolding);
		htmlContent := htmlContent.Replace("{{txtNumberOfTrx_A2AHolding_KickBack}}", PtxtNumberOfTrx_A2AHolding_KickBack);
		htmlContent := htmlContent.Replace("{{txtVaulterKickBackPerTry_A2AHolding_KickBack}}", PtxtVaulterKickBackPerTry_A2AHolding_KickBack);
		htmlContent := htmlContent.Replace("{{lblTotalIncome_A2AHolding_KickBack}}", PtotalIncome_A2AHolding_KickBack);
	) else (
		htmlContent := htmlContent.Replace("{{A2AHolding_hideDiv}}", "hideDiv");
	);
	
	htmlContent := htmlContent.Replace("{{t_calc_tblHeaderTotalTrx}}", Pt_calc_tblHeaderTotalTrx);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_CardTrx}}", Pt_calc_tblData_CardTrx);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_A2ATrx}}", Pt_calc_tblData_A2ATrx);
	htmlContent := htmlContent.Replace("{{t_calc_tblHeaderHolding}}", Pt_calc_tblHeaderHolding);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_CardTrx}}", Pt_calc_tblData_CardTrx);
	htmlContent := htmlContent.Replace("{{t_calc_tblData_A2ATrx}}", Pt_calc_tblData_A2ATrx);

	htmlContent := htmlContent.Replace("{{cntTotalTrx_card}}", PcntTotalTrx_card);
	htmlContent := htmlContent.Replace("{{cntTrx_card}}", PcntTrx_card);
	htmlContent := htmlContent.Replace("{{percTrx_card}}", PpercTrx_card);
	htmlContent := htmlContent.Replace("{{cntTrx_A2A}}", PcntTrx_A2A);
	htmlContent := htmlContent.Replace("{{percTrx_A2A}}", PpercTrx_A2A);
	htmlContent := htmlContent.Replace("{{cntTrx_cardHold}}", PcntTrx_cardHold);
	htmlContent := htmlContent.Replace("{{percTrx_cardHold}}", PpercTrx_cardHold);
	htmlContent := htmlContent.Replace("{{cntTrx_A2AHold}}", PcntTrx_A2AHold);
	htmlContent := htmlContent.Replace("{{percTrx_A2AHold}}", PpercTrx_A2AHold);
	
	
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
	{
		{
			Name: fileName + ".pdf",
			PDF: bytes
		}
	}
) 
catch
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);