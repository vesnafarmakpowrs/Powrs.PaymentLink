
Response.SetHeader("Access-Control-Allow-Origin","*");

({
   "userName": Required(Str(PUserName)),
   "nonce": Required(Str(PNonce)),
   "seconds" : Optional(Str(PSeconds)),
   "signature": Required(Str(PSignature))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

logObject := "";
logEventID := "LoginFeeCalculator.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try 
(
    if(System.String.IsNullOrWhiteSpace(PUserName) or System.String.IsNullOrWhiteSpace(PSignature) or System.String.IsNullOrWhiteSpace(PNonce)) then 
    (
		BadRequest("Username, Nonce and Signature could not be empty");
    );

	availableUsersList := Create(System.Collections.Generic.List, System.String);
	availableUsersList.Add("AgentPLG");
	availableUsersList.Add("Emir");
	availableUsersList.Add("Robert");
	
	if(!availableUsersList.Contains(PUserName))then
	(
		Forbidden("Invalid user name or password.");
	);
	logObject := PUserName;

    Log.Informational("Called method LoginSmartAdmin for userName :" + PUserName, logObject, logActor, logEventID, null);

    validInSeconds:= 1800;
    Resp:= null;

    Resp := POST
	(
		"https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
		{
			"userName": PUserName,
			"nonce": PNonce,
			"signature": PSignature,
			"seconds": validInSeconds
		},
		{"Accept" : "application/json"}
	);

	Destroy(PUserName);
	Destroy(PNonce);
	Destroy(PSignature);
     
	{	
		"jwt" : Resp.jwt,
		"validUntil": Now.AddSeconds(validInSeconds)
	}
)
catch
(
    Log.Error(Exception.Message, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
