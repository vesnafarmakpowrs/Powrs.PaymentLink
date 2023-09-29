({
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword))	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));

Response := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                     "nonce": Nonce,
	                "signature": Signature,
	                "seconds": 5
                  },
		   {"Accept" : "application/json"});

domain:= "https://" + Gateway.Domain;

{	
    "jwt" : Response.jwt
}

