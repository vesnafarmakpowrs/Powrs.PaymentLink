Response.SetHeader("Access-Control-Allow-Origin","*");

({
   "userName": Required(Str(PUserName)),
   "nonce": Required(Str(PNonce)),
   "signature": Required(Str(PSignature))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try 
(
    if(System.String.IsNullOrWhiteSpace(PUserName) or System.String.IsNullOrWhiteSpace(PSignature) or System.String.IsNullOrWhiteSpace(PNonce)) then 
    (
     BadRequest("Username, Nonce and Signature could not be empty");
    );

    validInSeconds:= 1800;
    Resp:= null;

    Resp := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                    "nonce": PNonce,
	            "signature": PSignature,
	            "seconds": validInSeconds
                  },
		   {"Accept" : "application/json"});

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
    Log.Error(Exception.Message, null);
    BadRequest(Exception.Message);
);