Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "userName":Required(Str(PUserName)),
    "password":Required(Str(PPassword)),
    "repeatedPassword":Required(Str(PRepeatedPassword)),
    "email" : Required(Str(PEmail))
}:=Posted) ??? BadRequest(Exception.Message);

try
(
    if(PEmail not like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}") then 
    (
      Error("Email in not valid format.")
    );    
     
    Code:= 0;
    if (!exists(Code:= Global.VerifyingNumbers[PEmail]) or Code >= 0) then 
    (
        Error("Email must be verified in order to create account");
    );

    if(PUserName not like "^[\\p{L}\\p{N}]{8,20}$") then 
    (
     Error("Username could only contain letters and numbers.")
    );
    if(PPassword != PRepeatedPassword) then
    (
        Error("Passwords does not match.");
    );

    if(PPassword not like "^(?=.*[\\p{Ll}])(?=.*[\\p{Lu}])(?=.*[\\p{N}])(?=.*[^\\p{L}\\p{N}])[^\\s]{8,}$") then 
    (
        Error("Password must contain at least one uppercase, lowercase, special char and number, and must be at least 8 characters long.")
    );

    if(!System.String.IsNullOrWhiteSpace(select top 1 UserName from BrokerAccounts where UserName = PUserName)) then 
    (
        Error("Account with " + PUserName + " already exists");
    );

    apiKey:= GetSetting("POWRS.PaymentLink.ApiKey", "");
    apiKeySecret:= GetSetting("POWRS.PaymentLink.ApiKeySecret", "");

    if(System.String.IsNullOrWhiteSpace(apiKey) or System.String.IsNullOrWhiteSpace(apiKeySecret)) then 
    (
        Error("Keys are missing");
    );

    Nonce:= Base64Encode(RandomBytes(32));
    S:= PUserName + ":" + Gateway.Domain + ":" + PEmail + ":" + PPassword + ":" + apiKey + ":" + Nonce;
    Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(apiKeySecret)));
    
    neuronDomain:= "https://" + Gateway.Domain;
    NewAccount:= POST(neuronDomain + "/Agent/Account/Create",
                 {
                    "apiKey": apiKey,
                    "eMail": PEmail,
	                "nonce": Nonce,
	                "password": PPassword,
                    "seconds": 1800,
                    "signature": Signature,
                    "userName": PUserName
                  },
		   {"Accept" : "application/json" });

    enabled:= Update BrokerAccounts set Enabled = true where UserName = PUserName;
    Global.VerifyingNumbers.Remove(PEmail);

   
 neuronDomain:= "https://" + Gateway.Domain;

try
(
    if(!exists(NewAccount.jwt)) then 
    (
	    BadRequest("Token not available in response.");
    );

    PLocalName:= "ed448";
    PNamespace:= "urn:ieee:iot:e2e:1.0";
    PKeyId:= NewGuid().ToString();
    KeyPassword:= Base64Encode(RandomBytes(20)).ToString();
    Nonce:= Base64Encode(RandomBytes(32)).ToString();

    S1:= PUserName + ":" + Gateway.Domain + ":" + PLocalName + ":" + PNamespace + ":" + PKeyId;
    KeySignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

    S2:= S1 + ":" + KeySignature + ":" + Nonce;
    RequestSignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

    NewKey:= POST(neuronDomain + "/Agent/Crypto/CreateKey",
                 {
                   "localName": PLocalName,
				    "namespace": PNamespace,
				    "id": PKeyId,
				    "nonce": Nonce,
				    "keySignature": KeySignature,
				    "requestSignature": RequestSignature
                  },
		   {"Accept" : "application/json",
            "Authorization": "Bearer " + NewAccount.jwt});
   
   SetSetting(PUserName  + ".KeyId", PKeyId);
   SetSetting(PUserName  + ".KeySecret", KeyPassword);
)
catch
(
  Log.Error("Unable to create key: " + Exception.Message, null);
  BadRequest(Exception.Message);
)
finally
(
    Destroy(Nonce);
    Destroy(S1);
    Destroy(KeySignature);
    Destroy(S2);
    Destroy(RequestSignature);
    Destroy(PKeyId);
    Destroy(KeySignature);
);

 {
        "userName": PUserName,
        "jwt": NewAccount.jwt,
        "isApproved": false
 }

)
catch
(
    Log.Error("Unable to create user: " + Exception.Message, null);
    BadRequest(Exception.Message);
)
finally
(
    Destroy(Nonce);
    Destroy(S);
    Destroy(Signature);
);