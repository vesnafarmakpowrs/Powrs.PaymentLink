({
    "userName":Required(Str(PUserName) like "[\\p{L}\\s]{2,20}"),
    "password":Required(Str(PPassword)),
    "email" : Required(Str(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "firstName" : Required(Str(PFirstName) like "[\\p{L}\\s]{2,20}"),
    "lastName" : Required(Str(PLastName) like "[\\p{L}\\s]{2,20}"),
    "personalNumber" : Required(Str(PPersonalNumber) like "\\d*-?\\d*"),
    "country" : Required(Str(PCountryCode) like "[A-Z]{2}")
}:=Posted) ??? BadRequest(Exception.Message);

try
(
  foreach document in Posted.Documents do 
  (   
  	if(System.String.IsNullOrWhiteSpace(document.type) or 
	   System.String.IsNullOrWhiteSpace(document.fileName) or 
	   System.String.IsNullOrWhiteSpace(document.content)) then
	   (
		BadRequest("Every document must contain type, fileName, content");
	   );
  );
)
catch
(
   BadRequest(Exception.Message);
);

username:= select top 1 UserName from BrokerAccounts where UserName = PUserName;
if(!System.String.IsNullOrEmpty(username)) then 
(
    BadRequest("Account with " + PUserName + " already exists");
);

NormalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PCountryCode,PPersonalNumber);
isPersonalNumberValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PCountryCode,NormalizedPersonalNumber);

if(!isPersonalNumberValid) then 
(
    BadRequest("Personal number: " + PPersonalNumber + " not valid for " +  PCountryCode);
);

neuronDomain:= "https://" + Gateway.Domain;

apiKey:= GetSetting("POWRS.PaymentLink.ApiKey", "");
apiKeySecret:= GetSetting("POWRS.PaymentLink.ApiKeySecret", "");

try
(
    Nonce:= Base64Encode(RandomBytes(32));
    S:= PUserName + ":" + Gateway.Domain + ":" + PEmail + ":" + PPassword + ":" + apiKey + ":" + Nonce;
    Signature := Base64Encode(Sha2_256HMac(Utf8Encode(S),Utf8Encode(apiKeySecret)));

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
		   {"Accept" : "application/json"}, {"Host": neuronDomain});
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

try
(
    enabled:= Update BrokerAccounts set Enabled = true where UserName = PUserName;
)
catch
(
  Log.Error("Unable to enable user: " + Exception.Message, null);
  BadRequest(Exception.Message);
);

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
);

try
(
 if(!SetSetting(PUserName + ".KeyId","") or !SetSetting(PUserName + ".KeySecret","")) then 
 (
  Error("Unable to set key and password in settings");
 );
)
catch
(
 Log.Error("Unable to save generated keys: " + Exception.Message, null);
 BadRequest(Exception.Message);
);

try
(  
    PropertiesVector:= [
                     {name: "FIRST", value: PFirstName},
                     {name: "LAST", value: PLastName},
                     {name: "PNR", value: NormalizedPersonalNumber},
                     {name: "COUNTRY", value: PCountryCode}
                    ];
   
    Nonce:= Base64Encode(RandomBytes(32));
    S1:= PUserName + ":" + Gateway.Domain + ":" + PLocalName + ":" + PNamespace + ":" + PKeyId;
    KeySignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

    S2:= S1 + ":" + KeySignature + ":" + Nonce;
     
    S2 += ":FIRST:" + PFirstName;
    S2 += ":LAST:" + PLastName;
    S2 += ":PNR:" + NormalizedPersonalNumber;
    S2 += ":COUNTRY:" + PCountryCode;

    RequestSignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

    NewIdentity:= POST(neuronDomain + "/Agent/Legal/ApplyId",
                 {
                    "keyId": Str(PKeyId),
	                "nonce": Str(Nonce),
	                "keySignature":  Str(KeySignature),
	                "requestSignature": Str(RequestSignature),
		    "Properties":  PropertiesVector
		 },
		   {"Accept" : "application/json",
		    "Authorization": "Bearer " + NewAccount.jwt,
		    "Referer": neuronDomain + "/VaulterApi/PaymentLink/Account/CreateAccount.ws"
		   });

)
catch
(
    Log.Error("Unable to apply for legal id: " + Exception.Message, null);
    BadRequest(Exception.Message);
)
finally
(
    Destroy(Nonce);
    Destroy(S1);
    Destroy(KeySignature);
    Destroy(S2);
    Destroy(RequestSignature);
);

if(exists(NewIdentity.Id)) then 
(
  BadRequest("Identity not created");
);

try
(
    foreach Document in Posted.Documents do 
    (
        try
        (
            Nonce:= Base64Encode(RandomBytes(32));
            S1:= PUserName + ":" + Gateway.Domain + ":" + PLocalName + ":" + PNamespace + ":" + PKeyId;
            KeySignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

            S2:= S1 + ":" + KeySignature + ":" + Nonce + ":" + Document.content + ":" + Document.fileName + ":" + Document.contentType;
            RequestSignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));

            NewKey:= POST(neuronDomain + "/Agent/Legal/AddIdAttachment",
                    {
                        "attachmentBase64": Document.content,
    				    "attachmentContentType": Document.contentType,
    				    "attachmentFileName": Document.fileName,
    				    "keyId": PKeyId,
    				    "keySignature": KeySignature,
    				    "legalId": NewIdentity.Id,
                        "nonce": Nonce,
                        "requestSignature": RequestSignature,
                     },
    		   {"Accept" : "application/json",
               "Authorization": "Bearer " + NewAccount.jwt});
        )
        catch
        (
            BadRequest("Unable to upload documents for legal identity: " + Exception.Message);
        )
        finally
        (
            Destroy(Nonce);
            Destroy(S1);
            Destroy(KeySignature);
            Destroy(RequestSignature);
        );
    );
)
catch
(
    BadRequest(Exception.Message);
);

Return("ok");
