({
    "txtCustomer": Required(Str(PtxtCustomer)),
    "txtCustomerID": Required(Str(PtxtCustomerID)),
    "txtTotalRevenue": Required(Str(PtxtTotalRevenue)),
    "txtNote": Required(Str(PtxtNote)),
	
	"chbxShowCard": Required(Str(PchbxShowCard)),
    "txtNumberOfTrx_Card": Required(Str(PtxtNumberOfTrx_Card)),
    "txtAverAmountPerTrx_Card": Required(Str(PtxtAverAmountPerTrx_Card)),
    "txtCardFee_Card": Required(Str(PtxtCardFee_Card)),
    "txtVaulterCardFee_Card": Required(Str(PtxtVaulterCardFee_Card)),
    "totalCost_Card": Required(Str(PtotalCost_Card)),
    "vaulterCost_Card": Required(Str(PvaulterCost_Card)),
    "saved_card": Required(Str(Psaved_card)),
    "business_card": Required(Str(Pbusiness_card)),
	
	"chbxShowA2A": Required(Str(PchbxShowA2A)),
	"txtNumberOfTrx_A2A": Required(Str(PtxtNumberOfTrx_A2A)),
    "txtAverAmountPerTrx_A2A": Required(Str(PtxtAverAmountPerTrx_A2A)),
    "txtVaulterA2AFee_A2A": Required(Str(PtxtVaulterA2AFee_A2A)),
    "vaulterCost_A2A": Required(Str(PvaulterCost_A2A)),
    "saved_A2A": Required(Str(Psaved_A2A)),
    "business_A2A": Required(Str(Pbusiness_A2A)),
	
	"chbxShowCardHolding": Required(Str(PchbxShowCardHolding)),
	"txtNumberOfTrx_CardHolding": Required(Str(PtxtNumberOfTrx_CardHolding)),
    "txtAverAmountPerTrx_CardHolding": Required(Str(PtxtAverAmountPerTrx_CardHolding)),
    "txtVaulterFee_CardHolding": Required(Str(PtxtVaulterFee_CardHolding)),
    "txtNumberOfTrx_CardHolding_KickBack": Required(Str(PtxtNumberOfTrx_CardHolding_KickBack)),
    "txtVaulterKickBackPerTry_CardHolding_KickBack": Required(Str(PtxtVaulterKickBackPerTry_CardHolding_KickBack)),
    "sliderSellerBuyer_CardHolding": Required(Str(PsliderSellerBuyer_CardHolding)),
    "TotalCost_CardHolding": Required(Str(PTotalCost_CardHolding)),
    "TotalIncome_CardHolding_KickBack": Required(Str(PTotalIncome_CardHolding_KickBack)),
	
	"chbxShowA2AHolding": Required(Str(PchbxShowA2AHolding)),
	"txtNumberOfTrx_A2AHolding": Required(Str(PtxtNumberOfTrx_A2AHolding)),
    "txtAverAmountPerTrx_A2AHolding": Required(Str(PtxtAverAmountPerTrx_A2AHolding)),
    "txtVaulterFee_A2AHolding": Required(Str(PtxtVaulterFee_A2AHolding)),
    "txtNumberOfTrx_A2AHolding_KickBack": Required(Str(PtxtNumberOfTrx_A2AHolding_KickBack)),
    "txtVaulterKickBackPerTry_A2AHolding_KickBack": Required(Str(PtxtVaulterKickBackPerTry_A2AHolding_KickBack)),
    "sliderSellerBuyer_A2AHolding": Required(Str(PsliderSellerBuyer_A2AHolding)),
    "TotalCost_A2AHolding": Required(Str(PTotalCost_A2AHolding)),
    "TotalIncome_A2AHolding_KickBack": Required(Str(PTotalIncome_A2AHolding_KickBack))
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