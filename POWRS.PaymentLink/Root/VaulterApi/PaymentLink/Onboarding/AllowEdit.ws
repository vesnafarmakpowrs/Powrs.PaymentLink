AuthenticateSession(Request,"User");
Authorize(User,"Admin.Onboarding.Modify");

({
	"ObjectId": Required(Str(PObjectId))
}:= Posted) ??? BadRequest(Exception.Message);

logObjectID := "Neuron User";
logEventID := "AllowEdit.ws";
logActor := Request.RemoteEndPoint;

try
(
	generalInfo:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where ObjectId = PObjectId;
	if(generalInfo == null) then(
		Error("ObjectId don't exists");
	);
	generalInfo.CanEdit := true;
	Waher.Persistence.Database.Update(generalInfo);

	Log.Informational("Succeffully allow edit onboarding for user: " + generalInfo.UserName, logObjectID, logActor, logEventID, null);
	
	{
		success: true
	}
)
catch
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

