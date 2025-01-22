({
    "id": Required(Str(Pid))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := "";
logEventID := "RegistrationLinkInfo.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	continueWithRegistration := false;
	idOnbjectInfo := select top 1 * from POWRS.PaymentLink.Models.NewUserRegistrationDetail where ObjectId = Pid;
	if(idOnbjectInfo != null) then
	(
		if(idOnbjectInfo.SuccessfullyRegisteredUserName = "")then
		(
			continueWithRegistration := true;
		);
	);
	
	{
		continueWithRegistration: continueWithRegistration
	}
)
catch
(
	Log.Error("Error: " + Exception.Message, logObject, logActor, logEventID, null);	
	BadRequest(Exception.Message);
);