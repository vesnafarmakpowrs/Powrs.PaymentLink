SessionUser:= Global.ValidateAgentApiToken(false, false);

logObjectID := SessionUser.username;
logEventID := "ApplyOnboardingData.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

errors:= Create(System.Collections.Generic.List, System.String);

try
(
	allCompaniesRootPath := GetSetting("POWRS.PaymentLink.OnBoardingAllCompaniesRootPath","");
	if(System.String.IsNullOrWhiteSpace(allCompaniesRootPath)) then (
		BadRequest("No setting: OnBoardingAllCompaniesRootPath");
	);
	
	
	
	Log.Informational("Succeffully onboarding apply.", logObjectID, logActor, logEventID, null);
	{
		success: true
	}
)
catch
(
	Log.Error("Unable to apply onboarding data: " + Exception.Message, logObjectID, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		BadRequest(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);