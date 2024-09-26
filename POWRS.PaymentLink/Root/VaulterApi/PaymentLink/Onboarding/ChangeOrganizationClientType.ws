AuthenticateSession(Request, "User");
Authorize(User,"Admin.Notarius.Identities");

({
	"objectId": Required(Str(PObjectId)),
	"type": Required(Str(PType))
}:= Posted) ??? BadRequest(Exception.Message);

logObject := "Neuron User";
logEventID := "ChangeOrganizationClientType.ws";
logActor := Request.RemoteEndPoint;

try
(
	newClientType := System.Enum.Parse(POWRS.PaymentLink.ClientType.Enums.ClientType, PType) ??? Error("Client type not valid");
	
	organizationClientType := Select top 1 * from POWRS.PaymentLink.ClientType.Models.OrganizationClientType where ObjectId = PObjectId;
	if(organizationClientType = null) then
	(
		Error("Organization don't exsits");
	);
	
	organizationClientType.OrgClientType := newClientType;
	Waher.Persistence.Database.Update(organizationClientType);

	Log.Informational("Succeffully change clinet type to: '" + PType + "' , for organization: '" + organizationClientType.OrganizationName + "'", logObject, logActor, logEventID, null);
	
	{
		success: true
	}
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
