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

    validInSeconds:= 1800;
    Resp:= null;

    Resp := POST("https://" +  Request.Header.Host.Value + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                    "nonce": PNonce,
	                "signature": PSignature,
	                "seconds": validInSeconds
                  },
		   {"Accept" : "application/json"});
    

     legalIdentity:= select top 1 Id from LegalIdentities where Account = PUserName and State = "Approved";

     Destroy(PUserName);
     Destroy(PNonce);
     Destroy(PSignature);
     
{	
    "jwt" : Resp.jwt,
    "validUntil": Now.AddSeconds(validInSeconds),
    "isApproved": !System.String.IsNullOrWhiteSpace(legalIdentity)
}

)
catch
(
    Log.Error(Exception.Message, null);
    BadRequest(Exception.Message);
);