AuthenticateSession(Request, "User");
Authorize(User,"Admin.Notarius.Identities");

({
	"objectId": Required(Str(PObjectId)),
	"type": Required(Str(PType))
}:= Posted) ??? BadRequest(Exception.Message);

logObject := "Neuron User";
logEventID := "ChangeBrokerAccountClientType.ws";
logActor := Request.RemoteEndPoint;

try
(
	newClientType := System.Enum.Parse(POWRS.PaymentLink.ClientType.Enums.ClientType, PType) ??? Error("Client type not valid");
	
	brokerAccClientType := Select top 1 * from POWRS.PaymentLink.ClientType.Models.BrokerAccountOnboaradingClientTypeTMP where ObjectId = PObjectId;
	if(brokerAccClientType = null) then
	(
		Error("Organization don't exsits");
	);
	
	brokerAccClientType.OrgClientType := newClientType;
	Waher.Persistence.Database.Update(brokerAccClientType);

	Log.Informational("Succeffully change clinet type to: '" + PType + "' , for user name: '" + brokerAccClientType.UserName + "'", logObject, logActor, logEventID, null);
	
	{
		success: true
	}
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
