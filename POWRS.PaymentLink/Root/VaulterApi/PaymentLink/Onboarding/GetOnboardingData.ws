SessionUser:= Global.ValidateAgentApiToken(false, false);

try
(
	POWRS.PaymentLink.Onboarding.Onboarding.GetOnboardingData(SessionUser.username);
)
catch
(
	Log.Error(Exception, "GetOnboardingData", SessionUser.username, null);
	BadRequest(Exception.Message);
);