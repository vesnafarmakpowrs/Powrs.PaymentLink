SessionUser:= Global.ValidateAgentApiToken(false, false);

({
	"FileType": Required(Str(PFileType))
}:= Posted) ??? BadRequest(Exception.Message);

logObjectID := SessionUser.username;
logEventID := "DownloadFile.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

try 
(
	fileRootPath := Waher.IoTGateway.Gateway.RootFolder + "VaulterApi\\PaymentLink\\Onboarding\\Template\\PaySpot";
	htmlTemplatePath := fileRootPath + "\\ZahtevZaUspostavljanjeSaradnje.html"; 
	if (!File.Exists(htmlTemplatePath)) then
		Error("File does not exist");
		
	htmlContent := System.IO.File.ReadAllText(htmlTemplatePath);
	
	fileName := "NewFile_" + "ZahtevZaUspostavljanjeSaradnje";
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
