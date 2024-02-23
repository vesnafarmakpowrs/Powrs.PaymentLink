
Response.SetHeader("Access-Control-Allow-Origin","*");

({
   "userName": Required(Str(PUserName)),
   "nonce": Required(Str(PNonce)),
   "seconds" : Optional(Str(PSeconds)),
   "signature": Required(Str(PSignature))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try 
(
    if(System.String.IsNullOrWhiteSpace(PUserName) or System.String.IsNullOrWhiteSpace(PSignature) or System.String.IsNullOrWhiteSpace(PNonce)) then 
    (
		BadRequest("Username, Nonce and Signature could not be empty");
    );

	if(PUserName != "PowrsAgent" && PUserName != "VaulterInvestor") then (
		BadRequest("Invalid user name or password.");
	);

    Log.Informational("Called method LoginSmartAdmin for userName :" + PUserName, "", "SmartAdmin",null);

    validInSeconds:= 1800;
    Resp:= null;

    Resp := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
					{
						"userName": PUserName,
						"nonce": PNonce,
						"signature": PSignature,
						"seconds": validInSeconds
					},
					{"Accept" : "application/json"}
				);

	role := "";
	if (PUserName == "PowrsAgent") then (
		role := "SuperAdmin";
	)else(
		role := "User";
	);

	Destroy(PUserName);
	Destroy(PNonce);
	Destroy(PSignature);
     
	{	
		"jwt" : Resp.jwt,
		"validUntil": Now.AddSeconds(validInSeconds),
		"role": role
	}
)
catch
(
    Log.Error(Exception.Message, "", "SmartAdmin", null);
    BadRequest(Exception.Message);
);
