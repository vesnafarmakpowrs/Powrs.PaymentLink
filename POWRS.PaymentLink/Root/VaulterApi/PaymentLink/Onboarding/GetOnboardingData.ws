SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "GetOnboardingData.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

try
(
	onBoardingData:= POWRS.PaymentLink.Onboarding.Onboarding.GetOnboardingData(SessionUser.username);
	Log.Informational("Succeffully get OnBoarding data. obj: " + Str(onBoardingData), logObject, logActor, logEventID, null);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

return (Generalize(onBoardingData));