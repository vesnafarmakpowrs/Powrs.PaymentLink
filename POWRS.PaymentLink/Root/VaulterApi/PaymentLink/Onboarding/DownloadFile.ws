﻿SessionUser:= Global.ValidateAgentApiToken(false, false);

({
	"FileName": Required(Str(PFileName))
}:= Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "DownloadFile.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try 
(
	if(System.String.IsNullOrWhiteSpace(PFileName)) then	
		Error("File name can't be empty");
	
	allCompaniesRootPath := GetSetting("POWRS.PaymentLink.OnBoardingAllCompaniesRootPath","");
	if(System.String.IsNullOrWhiteSpace(allCompaniesRootPath)) then (
		Error("No setting: OnBoardingAllCompaniesRootPath");
	);
	
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
	companySubDirPath := "\\" + generalInfo.OrganizationNumber;
	
	filePath := allCompaniesRootPath + companySubDirPath + "\\" + PFileName; 
	if (!File.Exists(filePath)) then
		Error("File does not exists");
	
    bytes := System.IO.File.ReadAllBytes(filePath);
	Log.Informational("Succeffully returned file:" + PFileName, logObject, logActor, logEventID, null);
	
	{
		File: bytes
	}
)
catch 
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
