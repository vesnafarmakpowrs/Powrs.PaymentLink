Response.SetHeader("Access-Control-Allow-Origin","*");

({
	"t_calc_Header": Required(Str(Pt_calc_Header)),
	"t_calc_Customer": Required(Str(Pt_calc_Customer)),
	"t_calc_CustomerID": Required(Str(Pt_calc_CustomerID)),
	"t_calc_TotalRevenue": Required(Str(Pt_calc_TotalRevenue)),
	
	"t_calc_CARD": Required(Str(Pt_calc_CARD)),
    "t_calc_NumberOfTrx_Card": Required(Str(Pt_calc_NumberOfTrx_Card)),
    "t_calc_AverAmountPerTrx_Card": Required(Str(Pt_calc_AverAmountPerTrx_Card)),
    "t_calc_CardFee_Card": Required(Str(Pt_calc_CardFee_Card)),
    "t_calc_totalCost_card": Required(Str(Pt_calc_totalCost_card)),
    "t_calc_VaulterCardFee_Card": Required(Str(Pt_calc_VaulterCardFee_Card)),
    "t_calc_totalVaulterCost_card": Required(Str(Pt_calc_totalVaulterCost_card)),
    "t_calc_SAVED_card": Required(Str(Pt_calc_SAVED_card)),
    "t_calc_BUSINESS_card": Required(Str(Pt_calc_BUSINESS_card)),
	
	"t_calc_A2A": Required(Str(Pt_calc_A2A)),
	"t_calc_NumberOfTrx_A2A": Required(Str(Pt_calc_NumberOfTrx_A2A)),
	"t_calc_AverAmountPerTrx_A2A": Required(Str(Pt_calc_AverAmountPerTrx_A2A)),
	"t_calc_VaulterA2AFee_A2A": Required(Str(Pt_calc_VaulterA2AFee_A2A)),
	"t_calc_totalVaulterCost_A2A": Required(Str(Pt_calc_totalVaulterCost_A2A)),
	"t_calc_SAVED_A2A": Required(Str(Pt_calc_SAVED_A2A)),
	"t_calc_BUSINESS_A2A": Required(Str(Pt_calc_BUSINESS_A2A)),
	
	"t_calc_CARD_holding": Required(Str(Pt_calc_CARD_holding)),
	"t_calc_NumberOfTrx_CardHolding": Required(Str(Pt_calc_NumberOfTrx_CardHolding)),
	"t_calc_AverAmountPerTrx_CardHolding": Required(Str(Pt_calc_AverAmountPerTrx_CardHolding)),
	"t_calc_VaulterFee_CardHolding": Required(Str(Pt_calc_VaulterFee_CardHolding)),
	"t_calc_totalCost_CardHolding": Required(Str(Pt_calc_totalCost_CardHolding)),
	"t_calc_KickBack_card": Required(Str(Pt_calc_KickBack_card)),
	"t_calc_NumberOfTrx_CardHolding_KickBack": Required(Str(Pt_calc_NumberOfTrx_CardHolding_KickBack)),
	"t_calc_VaulterKickBackPerTry_CardHolding_KickBack": Required(Str(Pt_calc_VaulterKickBackPerTry_CardHolding_KickBack)),
	"t_calc_totalIncome_CardHolding_KickBack": Required(Str(Pt_calc_totalIncome_CardHolding_KickBack)),
	
	"t_calc_A2A_holding": Required(Str(Pt_calc_A2A_holding)),
	"t_calc_NumberOfTrx_A2AHolding": Required(Str(Pt_calc_NumberOfTrx_A2AHolding)),
	"t_calc_AverAmountPerTrx_A2AHolding": Required(Str(Pt_calc_AverAmountPerTrx_A2AHolding)),
	"t_calc_VaulterFee_A2AHolding": Required(Str(Pt_calc_VaulterFee_A2AHolding)),
	"t_calc_totalCost_A2AHolding": Required(Str(Pt_calc_totalCost_A2AHolding)),
	"t_calc_KickBack_A2A": Required(Str(Pt_calc_KickBack_A2A)),
	"t_calc_NumberOfTrx_A2AHolding_KickBack": Required(Str(Pt_calc_NumberOfTrx_A2AHolding_KickBack)),
	"t_calc_VaulterKickBackPerTry_A2AHolding_KickBack": Required(Str(Pt_calc_VaulterKickBackPerTry_A2AHolding_KickBack)),
	"t_calc_totalIncome_A2AHolding_KickBack": Required(Str(Pt_calc_totalIncome_A2AHolding_KickBack)),
	
	"t_slider_lblHeader": Required(Str(Pt_slider_lblHeader)),
	"t_slider_lblSeller": Required(Str(Pt_slider_lblSeller)),
	"t_slider_lblBuyer": Required(Str(Pt_slider_lblBuyer)),
	
	"t_calc_Note": Required(Str(Pt_calc_Note)),
	
	"t_calc_tblHeaderTotalTrx": Required(Str(Pt_calc_tblHeaderTotalTrx)),
	"t_calc_tblData_CardTrx": Required(Str(Pt_calc_tblData_CardTrx)),
	"t_calc_tblData_A2ATrx": Required(Str(Pt_calc_tblData_A2ATrx)),
	"t_calc_tblHeaderHolding": Required(Str(Pt_calc_tblHeaderHolding)),
    
	"txtCustomer": Required(Str(PtxtCustomer)),
    "txtCustomerID": Required(Str(PtxtCustomerID)),
    "txtTotalRevenue": Required(Str(PtxtTotalRevenue)),
    "txtNote": Required(Str(PtxtNote)),
	
	"chbxShowCard": Required(Bool(PchbxShowCard)),
    "txtNumberOfTrx_Card": Required(Str(PtxtNumberOfTrx_Card)),
    "txtAverAmountPerTrx_Card": Required(Str(PtxtAverAmountPerTrx_Card)),
    "txtCardFee_Card": Required(Str(PtxtCardFee_Card)),
    "txtVaulterCardFee_Card": Required(Str(PtxtVaulterCardFee_Card)),
    "totalCost_Card": Required(Str(PtotalCost_Card)),
    "vaulterCost_Card": Required(Str(PvaulterCost_Card)),
    "saved_card": Required(Str(Psaved_card)),
    "business_card": Required(Str(Pbusiness_card)),
	
	"chbxShowA2A": Required(Bool(PchbxShowA2A)),
	"txtNumberOfTrx_A2A": Required(Str(PtxtNumberOfTrx_A2A)),
    "txtAverAmountPerTrx_A2A": Required(Str(PtxtAverAmountPerTrx_A2A)),
    "txtVaulterA2AFee_A2A": Required(Str(PtxtVaulterA2AFee_A2A)),
    "vaulterCost_A2A": Required(Str(PvaulterCost_A2A)),
    "saved_A2A": Required(Str(Psaved_A2A)),
    "business_A2A": Required(Str(Pbusiness_A2A)),
	
	"chbxShowCardHolding": Required(Bool(PchbxShowCardHolding)),
	"txtNumberOfTrx_CardHolding": Required(Str(PtxtNumberOfTrx_CardHolding)),
    "txtAverAmountPerTrx_CardHolding": Required(Str(PtxtAverAmountPerTrx_CardHolding)),
    "txtVaulterFee_CardHolding": Required(Str(PtxtVaulterFee_CardHolding)),
    "txtNumberOfTrx_CardHolding_KickBack": Required(Str(PtxtNumberOfTrx_CardHolding_KickBack)),
    "txtVaulterKickBackPerTry_CardHolding_KickBack": Required(Str(PtxtVaulterKickBackPerTry_CardHolding_KickBack)),
    "sliderSellerBuyer_CardHolding": Required(Str(PsliderSellerBuyer_CardHolding)),
    "totalCost_CardHolding": Required(Str(PtotalCost_CardHolding)),
    "totalIncome_CardHolding_KickBack": Required(Str(PtotalIncome_CardHolding_KickBack)),
	
	"chbxShowA2AHolding": Required(Bool(PchbxShowA2AHolding)),
	"txtNumberOfTrx_A2AHolding": Required(Str(PtxtNumberOfTrx_A2AHolding)),
    "txtAverAmountPerTrx_A2AHolding": Required(Str(PtxtAverAmountPerTrx_A2AHolding)),
    "txtVaulterFee_A2AHolding": Required(Str(PtxtVaulterFee_A2AHolding)),
    "txtNumberOfTrx_A2AHolding_KickBack": Required(Str(PtxtNumberOfTrx_A2AHolding_KickBack)),
    "txtVaulterKickBackPerTry_A2AHolding_KickBack": Required(Str(PtxtVaulterKickBackPerTry_A2AHolding_KickBack)),
    "sliderSellerBuyer_A2AHolding": Required(Str(PsliderSellerBuyer_A2AHolding)),
    "totalCost_A2AHolding": Required(Str(PtotalCost_A2AHolding)),
    "totalIncome_A2AHolding_KickBack": Required(Str(PtotalIncome_A2AHolding_KickBack)),
	
	"cntTotalTrx_card": Required(Str(PcntTotalTrx_card)),
	"cntTrx_card": Required(Str(PcntTrx_card)),
	"percTrx_card": Required(Str(PpercTrx_card)),
	"cntTrx_A2A": Required(Str(PcntTrx_A2A)),
	"percTrx_A2A": Required(Str(PpercTrx_A2A)),
	"cntTrx_cardHold": Required(Str(PcntTrx_cardHold)),
	"percTrx_cardHold": Required(Str(PpercTrx_cardHold)),
	"cntTrx_A2AHold": Required(Str(PcntTrx_A2AHold)),
	"percTrx_A2AHold": Required(Str(PpercTrx_A2AHold))
	
	
}:= Posted) ??? BadRequest(Exception.Message);

logObjectID := "TestKorisnik";
logEventID := "GenerateFormPDF.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

try
(
	
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\FeeCalculator\\HtmlTemplates\\FeeCalculatorForm";
	htmlTemplatePath := fileRootPath + "\\FeeCalc.html"; 
	if (!File.Exists(htmlTemplatePath)) then
		Error("Template path does not exist");
		
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	htmlContent := htmlContent.Replace("{{t_calc_Header}}", Pt_calc_Header);
	htmlContent := htmlContent.Replace("{{t_calc_Customer}}", Pt_calc_Customer);
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