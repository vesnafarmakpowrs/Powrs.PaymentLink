({
    "userName":Required(Str(PUserName) like "[\\p{L}\\s]{2,20}"),
    "password":Required(Str(PPassword)),
    "email" : Required(Str(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "firstName" : Required(Str(PFirstName) like "[\\p{L}\\s]{2,20}"),
    "lastName" : Required(Str(PLastName) like "[\\p{L}\\s]{2,20}"),
    "personalNumber" : Required(Str(PPersonalNumber) like "\\d*-?\\d*"),
    "country" : Required(Str(PCountryCode) like "[A-Z]{2}")
}:=Posted) ??? BadRequest(Exception.Message);

username:= select top 1 UserName from BrokerAccounts where UserName = PUserName;
if(System.String.IsNullOrEmpty(username)) then
(
    BadRequest("Account with " + PUserName + " does not exists");
);

NormalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PCountryCode,PPersonalNumber);
isPersonalNumberValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PCountryCode,NormalizedPersonalNumber);

if(!isPersonalNumberValid) then 
(
    BadRequest("Personal number: " + PPersonalNumber + " not valid for " +  PCountryCode);
);

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

Return("ok");
