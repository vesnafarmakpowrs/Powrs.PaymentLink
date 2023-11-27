({
   "userName": Required(Str(PUserName)),
   "nonce": Required(Str(PNonce)),
   "signature": Required(Str(PSignature))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Response.SetHeader("Access-Control-Allow-Origin","*");

if(System.String.IsNullOrWhiteSpace(PUserName) or System.String.IsNullOrWhiteSpace(PSignature) or System.String.IsNullOrWhiteSpace(PNonce)) then 
(
 BadRequest("Username, Nonce and Signature could not be empty");
);

validInSeconds:= 1800;
Resp:= null;
try 
(
  Resp := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                    "nonce": PNonce,
	            "signature": PSignature,
	            "seconds": validInSeconds
                  },
		   {"Accept" : "application/json"});
)
catch
(
 Log.Error(Exception.Message, null);
 BadRequest(Exception.Message);
);

Destroy(PUserName);
Destroy(PNonce);
Destroy(PSignature);

{	
    "jwt" : Resp.jwt,
    "validUntil": Now.AddSeconds(validInSeconds)
}