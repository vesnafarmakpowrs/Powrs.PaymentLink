({
   "userName": PUserName,
   "nonce": Nonce,
   "signature": Signature,
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Response.SetHeader("Access-Control-Allow-Origin","*");

if(System.String.IsNullOrWhiteSpace(PUserName) or System.String.IsNullOrWhiteSpace(Signature) or System.String.IsNullOrWhiteSpace(Nonce)) then 
(
 BadRequest("Username, Nonce and Signature could not be empty");
);

validInSeconds:= 1800;

Resp := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                    "nonce": Nonce,
	                "signature": Signature,
	                "seconds": validInSeconds
                  },
		   {"Accept" : "application/json"});

domain:= "https://" + Gateway.Domain;

Destroy(PUserName);
Destroy(Nonce);
Destroy(Signature);

{	
    "jwt" : Resp.jwt,
    "validUntil": Now.AddSeconds(validInSeconds)
}