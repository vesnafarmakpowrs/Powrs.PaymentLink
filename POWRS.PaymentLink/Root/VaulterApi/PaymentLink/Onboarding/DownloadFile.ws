SessionUser:= Global.ValidateAgentApiToken(false, false);

({
	"FileName": Required(Str(PFileName))
}:= Posted) ??? BadRequest(Exception.Message);

logObjectID := SessionUser.username;
logEventID := "DownloadFile.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

try 
(
	if(System.String.IsNullOrWhiteSpace(PFileName)) then	
		Error("File name can't be empty");
	
	allCompaniesPath := GetSetting("POWRS.PaymentLink.OnBoardingFileRootPath","");
	if(System.String.IsNullOrWhiteSpace(allCompaniesPath)) then (
		Error("No setting: OnBoardingFileRootPath");
	);
	
	filePath := allCompaniesPath + PFileName; 
	if (!File.Exists(filePath)) then
		Error("File does not exists");
	
	Log.Informational("Succeffully returned file:" + PFileName, logObjectID, logActor, logEventID, null);
	
    bytes := System.IO.File.ReadAllBytes(filePath);
	{
		{
			File: bytes
		}
	}
)
catch 
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
