Response.SetHeader("Access-Control-Allow-Origin","*");
({
    "email" : Required(Str(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "firstName" : Required(Str(PFirstName) like "[\\p{L}\\s]{2,20}"),
    "lastName" : Required(Str(PLastName) like "[\\p{L}\\s]{2,20}"),
    "personalNumber" : Required(Str(PPersonalNumber) like "\\d*-?\\d*"),
    "country" : Required(Str(PCountryCode) like "[A-Z]{2}"),
    "orgName": Required(Str(POrgName)),
    "orgNumber": Required(Str(POrgNumber)),
    "orgCity": Required(Str(POrgCity)),
    "orgCountry": Required(Str(POrgCountry)),
    "orgAddr": Required(Str(POrgAddress)),
    "orgAddr2": Required(Str(POrgAddress2)),
    "orgBankNum": Required(Str(POrgBankNum)),
    "orgDept": Required(Str(POrgDept)),
    "orgRole": Required(Str(POrgRole))
}:=Posted) ??? BadRequest(Exception.Message);


SessionUser:= Global.ValidateAgentApiToken(false);

try
(
    Password:= select top 1 Password from BrokerAccounts where UserName = SessionUser.username;
    if(System.String.IsNullOrWhiteSpace(Password)) then 
        Error("No user with given username");

    NormalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PCountryCode,PPersonalNumber);
    isPersonalNumberValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PCountryCode,NormalizedPersonalNumber);

    if(!isPersonalNumberValid) then 
     (
       BadRequest("Personal number: " + PPersonalNumber + " not valid for " +  PCountryCode);
     );

     neuronDomain:= "https://" + Gateway.Domain;

    PropertiesVector:= [
                          {name: "FIRST", value: PFirstName},
                          {name: "LAST", value: PLastName},
                          {name: "PNR", value: NormalizedPersonalNumber},
                          {name: "COUNTRY", value: PCountryCode},
		          {name: "ORGNAME", value: POrgName},
		          {name: "ORGNR", value: POrgNumber},
                          {name: "ORGCITY", value: POrgCity},
 		          {name: "ORGCOUNTRY", value: POrgCountry},
		          {name: "ORGADDR", value: POrgAddress},
           	          {name: "ORGADDR2", value: POrgAddress2},
                          {name: "ORGBANKNUM", value: POrgBankNum},
                          {name: "ORGDEPT", value: POrgDept},
                          {name: "ORGROLE", value: POrgRole}
                    ];

    KeyId := GetSetting(SessionUser.username + ".KeyId","");
    KeyPassword:= GetSetting(SessionUser.username + ".KeySecret","");

    if(System.String.IsNullOrEmpty(KeyId) || System.String.IsNullOrEmpty(KeyPassword)) then 
        Error("No signing keys or password available for user: " + SessionUser.username);
   
    Nonce:= Base64Encode(RandomBytes(32));
    S1:= SessionUser.username + ":" + Gateway.Domain + ":" + PLocalName + ":" + PNamespace + ":" + KeyId;
    KeySignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

    S2:= S1 + ":" + KeySignature + ":" + Nonce;

    foreach p in PropertiesVector do
    (
       S2 := S2 + ":" + p.name + ":" + p.value;
    );

    RequestSignature:= Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(Password)));

    NewIdentity:= POST(neuronDomain + "/Agent/Legal/ApplyId",
                 {
                    "keyId": Str(KeyId),
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

if(exists(!NewIdentity.Id)) then 
(
  BadRequest("Identity not created");
);

Return("ok");
