({
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
    "totalIncome_A2AHolding_KickBack": Required(Str(PtotalIncome_A2AHolding_KickBack))
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
	
	htmlContent := htmlContent.Replace("{{txtCustomer}}", PtxtCustomer);
	htmlContent := htmlContent.Replace("{{txtCustomerID}}", PtxtCustomerID);
	htmlContent := htmlContent.Replace("{{txtTotalRevenue}}", PtxtTotalRevenue);
	
	htmlContent := htmlContent.Replace("{{txtNumberOfTrx_Card}}", PtxtNumberOfTrx_Card);
	htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_Card}}", PtxtAverAmountPerTrx_Card);
	htmlContent := htmlContent.Replace("{{txtCardFee_Card}}", PtxtCardFee_Card);
	htmlContent := htmlContent.Replace("{{lblTotalCost_Card}}", PtotalCost_Card);
	htmlContent := htmlContent.Replace("{{txtVaulterCardFee_Card}}", PtxtVaulterCardFee_Card);
	htmlContent := htmlContent.Replace("{{lblVaulterCost_Card}}", PvaulterCost_Card);
	htmlContent := htmlContent.Replace("{{lblSaved_card}}", Psaved_card);
	htmlContent := htmlContent.Replace("{{lblBusiness_card}}", Pbusiness_card);

	htmlContent := htmlContent.Replace("{{txtNumberOfTrx_A2A}}", PtxtNumberOfTrx_A2A);
	htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_A2A}}", PtxtAverAmountPerTrx_A2A);
	htmlContent := htmlContent.Replace("{{txtVaulterA2AFee_A2A}}", PtxtVaulterA2AFee_A2A);
	htmlContent := htmlContent.Replace("{{lblVaulterCost_A2A}}", PvaulterCost_A2A);
	htmlContent := htmlContent.Replace("{{lblSaved_A2A}}", Psaved_A2A);
	htmlContent := htmlContent.Replace("{{lblBusiness_A2A}}", Pbusiness_A2A);
	
	htmlContent := htmlContent.Replace("{{txtNumberOfTrx_CardHolding}}", PtxtNumberOfTrx_CardHolding);
	htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_CardHolding}}", PtxtAverAmountPerTrx_CardHolding);
	htmlContent := htmlContent.Replace("{{txtVaulterFee_CardHolding}}", PtxtVaulterFee_CardHolding);
	htmlContent := htmlContent.Replace("{{lblTotalCost_CardHolding}}", PtotalCost_CardHolding);
	htmlContent := htmlContent.Replace("{{sliderSellerBuyer_CardHolding}}", PsliderSellerBuyer_CardHolding);
	htmlContent := htmlContent.Replace("{{txtNumberOfTrx_CardHolding_KickBack}}", PtxtNumberOfTrx_CardHolding_KickBack);
	htmlContent := htmlContent.Replace("{{txtVaulterKickBackPerTry_CardHolding_KickBack}}", PtxtVaulterKickBackPerTry_CardHolding_KickBack);
	htmlContent := htmlContent.Replace("{{lblTotalIncome_CardHolding_KickBack}}", PtotalIncome_CardHolding_KickBack);

	htmlContent := htmlContent.Replace("{{txtNumberOfTrx_A2AHolding}}", PtxtNumberOfTrx_A2AHolding);
	htmlContent := htmlContent.Replace("{{txtAverAmountPerTrx_A2AHolding}}", PtxtAverAmountPerTrx_A2AHolding);
	htmlContent := htmlContent.Replace("{{txtVaulterFee_A2AHolding}}", PtxtVaulterFee_A2AHolding);
	htmlContent := htmlContent.Replace("{{lblTotalCost_A2AHolding}}", PtotalCost_A2AHolding);
	htmlContent := htmlContent.Replace("{{sliderSellerBuyer_A2AHolding}}", PsliderSellerBuyer_A2AHolding);
	htmlContent := htmlContent.Replace("{{txtNumberOfTrx_A2AHolding_KickBack}}", PtxtNumberOfTrx_A2AHolding_KickBack);
	htmlContent := htmlContent.Replace("{{txtVaulterKickBackPerTry_A2AHolding_KickBack}}", PtxtVaulterKickBackPerTry_A2AHolding_KickBack);
	htmlContent := htmlContent.Replace("{{lblTotalIncome_A2AHolding_KickBack}}", PtotalIncome_A2AHolding_KickBack);
	
	fileName := "NewFile";
	newHtmlPath:= fileRootPath + "\\" + fileName + ".html";
	System.IO.File.WriteAllText(newHtmlPath, htmlContent, System.Text.Encoding.UTF8);
	pdfPath:= fileRootPath + "\\" + fileName + ".pdf";
	
	Log.Informational(
		"fileRootPath: " + fileRootPath 
		+ "\n newHtmlPath: " + newHtmlPath 
		+ "\n pdfPath: " + pdfPath
		, logObjectID, logActor, logEventID, null);
	
	Log.Informational(
		"command: " 
		+ "--allow \"" + fileRootPath + "\""
		+ " \"" + newHtmlPath + "\"" 
		+ " \"" +  pdfPath + "\""
		, logObjectID, logActor, logEventID, null);
	
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