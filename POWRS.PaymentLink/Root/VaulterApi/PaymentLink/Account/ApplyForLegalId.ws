Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(false, false);

({
    "firstName" : Required(Str(PFirstName)),
    "lastName" : Required(Str(PLastName) ),
    "personalNumber" : Required(Str(PPersonalNumber) ),
    "country" : Required(Str(PCountryCode)),
    "orgName": Required(Str(POrgName)),
    "orgNumber": Required(Str(POrgNumber)),
    "orgCity": Required(Str(POrgCity)),
    "orgCountry": Required(Str(POrgCountry)),
    "orgAddr": Required(Str(POrgAddress)) ,
    "orgAddr2": Required(Str(POrgAddress2)),
    "orgBankNum": Required(Str(POrgBankNum)),
    "orgDept": Required(Str(POrgDept)),
    "orgRole": Required(Str(POrgRole)),
    "orgActivity":  Required(Str(POrgActivity)),
    "orgActivityNumber":  Required(Str(POrgActivityNumber)),
    "orgTaxNumber":  Required(Str(POrgTaxNumber))
}:=Posted) ??? BadRequest("Request does not conform to the specification");

try
(
    if(PFirstName not like "[\\p{L}\\s]{2,30}") then 
(
    Error("First name not valid.");
);
if(PLastName not like "[\\p{L}\\s]{2,30}") then 
(
    Error("Last name not valid.");
);
if(PPersonalNumber not like "^\\d{13}$") then 
(
    Error("Personal number not valid.");
);
if(PCountryCode like "[A-Z]{2}") then 
(
    Error("Country code not valid.");
);
if(POrgName not like "^[\\p{L}\\s]{1,100}$") then 
(
    Error("Organization name not valid.");
);
if(POrgNumber not like "\\d{8,9}$") then 
(
    Error("Org number not valid.");
);
if(POrgCity not like "\\p{L}{2,50}$") then 
(
    Error("OrgCity not valid.");
);
if(POrgCountry not like "\\p{L}{2,50}$") then 
(
    Error("OrgCountry not valid.");
);
if(POrgAddress not like "^[\\p{L}\\p{N}\\s]{1,100}$") then 
(
    Error("OrgAddress not valid.");
);

if(POrgAddress2 not like "^[\\p{L}\\p{N}\\s]{1,100}$") then 
(
    Error("OrgAddress2 name not valid.");
);

if(POrgBankNum not like "^(?!.*--)[\\d-]{1,25}$") then 
(
    Error("BankNumber name not valid.");
);

if(POrgDept not like "\\p{L}{2,50}$") then 
(
    Error("Department name not valid.");
);

if(POrgRole not like "\\p{L}{2,50}$") then 
(
    Error("OrgRole not valid.");
);

if(POrgActivity not like "^[\\p{L}\\s]{1,100}$") then 
(
    Error("OrgActivity not valid.");
);

if(POrgActivityNumber not like "\\d{4,5}$") then 
(
    Error("ActivityNumber not valid.");
);

if(POrgTaxNumber not like "\\d{9,10}$") then
(
    Error("TaxNumber not valid.");
);

    Password:= select top 1 Password from BrokerAccounts where UserName = SessionUser.username;
    if(System.String.IsNullOrWhiteSpace(Password)) then 
    (
        Error("No user with given username");
    );

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
                          {name: "ORGROLE", value: POrgRole},
                          {name: "ORGACTIVITY", value: POrgActivity},
                          {name: "ORGACTIVITYNUM", value: POrgActivityNumber},
                          {name: "ORGTAXNUM", value: POrgTaxNumber}
                    ];
    PLocalName:= "ed448";
    PNamespace:= "urn:ieee:iot:e2e:1.0";

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
		    "Authorization": "Bearer " + SessionUser.jwt,
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
