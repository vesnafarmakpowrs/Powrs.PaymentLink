({
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword)),
    "duration":Optional(Int(PDuration) <= 3600)
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

if(System.String.IsNullOrWhiteSpace(PUserName) or System.String.IsNullOrWhiteSpace(PPassword)) then 
(
 BadRequest("Username and Password could not be empty");
);

if(!exists(PDuration)) then 
(
 PDuration:= 60;
);

Nonce := Base64Encode(RandomBytes(32));
S := PUserName + ":" + Waher.IoTGateway.Gateway.Domain + ":" + Nonce;

Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(PPassword)));

Resp := POST("https://" +  Waher.IoTGateway.Gateway.Domain + "/Agent/Account/Login",
                 {
                    "userName": PUserName,
                    "nonce": Nonce,
	                "signature": Signature,
	                "seconds": PDuration
                  },
		   {"Accept" : "application/json"});

domain:= "https://" + Gateway.Domain;

{	
    "jwt" : Resp.jwt
}

