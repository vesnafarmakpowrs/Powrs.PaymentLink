Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(false, false);

({
    "FIRST": Required(Str(PFirstName)),
    "LAST": Required(Str(PLastName)),
    "PNR": Required(Str(PPersonalNumber) ),
    "COUNTRY": Required(Str(PCountryCode)),
    "ORGNAME": Required(Str(POrgName)),
    "ORGNR": Required(Str(POrgNumber)),
    "ORGCITY": Required(Str(POrgCity)),
    "ORGCOUNTRY": Required(Str(POrgCountry)),
    "ORGADDR": Required(Str(POrgAddress)),
    "ORGADDR2": Optional(Str(POrgAddress2)),
    "ORGBANKNUM": Required(Str(POrgBankNum)),
    "ORGDEPT": Required(Str(POrgDept)),
    "ORGROLE": Required(Str(POrgRole)),
    "ORGACTIVITY": Required(Str(POrgActivity)),
    "ORGACTIVITYNUM": Required(Str(POrgActivityNumber)),
    "ORGTAXNUM": Required(Str(POrgTaxNumber)),
    "IPSONLY": Required(Str(PIpsOnly))
}:=Posted) ??? BadRequest("Request does not conform to the specification");

logObjectID := SessionUser.username;
logEventID := "ApplyForLegalId.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

try
(
	Password:= select top 1 Password from BrokerAccounts where UserName = SessionUser.username;
	if(System.String.IsNullOrWhiteSpace(Password)) then 
	(
		Error("No user with given username");
	);

	errors:= Create(System.Collections.Generic.List, System.String);

	POrgAddress2 := POrgAddress2 ?? "";

	if(PFirstName not like "[\\p{L}\\s]{2,30}") then 
	(
		errors.Add("FIRST");    
	);
	if(PLastName not like "[\\p{L}\\s]{2,30}") then 
	(
		errors.Add("LAST");
	);

	boolResult:= null;
	if(!System.Boolean.TryParse(PIpsOnly, boolResult)) then 
	(
		errors.Add("IPSONLY");
	);

	NormalizedPersonalNumber:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.Normalize(PCountryCode,PPersonalNumber);
	isPersonalNumberValid:= Waher.Service.IoTBroker.Legal.Identity.PersonalNumberSchemes.IsValid(PCountryCode,NormalizedPersonalNumber);

	if(PPersonalNumber not like "^\\d{13}$" or isPersonalNumberValid != true) then 
	(
		errors.Add("PNR");
	);
	if(PCountryCode not like "[A-Z]{2}") then 
	(
		errors.Add("COUNTRY");
	);
	if(POrgName not like "^[\\p{L}][\\p{L}\\s.\&,?]*[\\p{L}?]{2,100}$") then 
	(
		errors.Add("ORGNAME");
	);
	if(POrgNumber not like "\\d{8,10}$") then 
	(
		errors.Add("ORGNR");
	);
	if(POrgCity not like "[\\p{L}\\s]{2,50}$") then 
	(
		errors.Add("ORGCITY");
	);
	if(POrgCountry not like "[\\p{L}\\s]{2,50}$") then 
	(
		errors.Add("ORGCOUNTRY");
	);
	if(POrgAddress not like "^[\\p{L}\\p{N}\\s]{3,100}$") then 
	(
		errors.Add("ORGADDR");
	);


	if(POrgAddress2 != "" && POrgAddress2 not like "^[\\p{L}\\p{N}\\s]{3,100}$") then 
	(
		errors.Add("ORGADDR2");
	);

	if(POrgBankNum not like "^(?!.*--)[\\d-]{1,25}$") then 
	(
		errors.Add("ORGBANKNUM");
	);

	if(POrgDept not like "^[\\p{L}][\\p{L}\\s,?]*[\\p{L}?]{1,100}$") then 
	(
		errors.Add("ORGDEPT");
	);

	if(POrgRole not like "^[\\p{L}][\\p{L}\\s,?]*[\\p{L}?]{2,50}$") then 
	(
		errors.Add("ORGROLE");
	);

	if(POrgActivity not like "^[\\p{L}\\s]{1,100}$") then 
	(
		errors.Add("ORGACTIVITY");
	);

	if(POrgActivityNumber not like "\\d{4,5}$") then 
	(
		errors.Add("ORGACTIVITYNUM");
	);

	if(POrgTaxNumber not like "\\d{8,10}$") then
	(
		errors.Add("ORGTAXNUM");
	);

	if(errors.Count > 0) then
	(
		Error(errors);
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
	    {name: "ORGADDR2", value: (POrgAddress2 != "" ? POrgAddress2 : " ")},
		{name: "ORGBANKNUM", value: POrgBankNum},
		{name: "ORGDEPT", value: POrgDept},
		{name: "ORGROLE", value: POrgRole},
		{name: "ORGACTIVITY", value: POrgActivity},
		{name: "ORGACTIVITYNUM", value: POrgActivityNumber},
		{name: "ORGTAXNUM", value: POrgTaxNumber},
        {name: "IPSONLY", value: Str(PIpsOnly)}
	];
    PLocalName:= "ed448";
    PNamespace:= "urn:ieee:iot:e2e:1.0";

    KeyId := GetSetting(SessionUser.username + ".KeyId","");
    KeyPassword:= GetSetting(SessionUser.username + ".KeySecret","");

    if(System.String.IsNullOrEmpty(KeyId) or System.String.IsNullOrEmpty(KeyPassword)) then 
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

    NewIdentity:= POST(
		neuronDomain + "/Agent/Legal/ApplyId",
		{
			"keyId": Str(KeyId),
			"nonce": Str(Nonce),
			"keySignature":  Str(KeySignature),
			"requestSignature": Str(RequestSignature),
			"Properties":  PropertiesVector
		},
		{
			"Accept" : "application/json",
			"Authorization": "Bearer " + SessionUser.jwt,
			"Referer": neuronDomain + "/VaulterApi/PaymentLink/Account/CreateAccount.ws"
		}
	);

	accountRole := Select top 1 * 
	from POWRS.PaymentLink.Models.BrokerAccountRole
	where UserName = SessionUser.username;
	
	if(accountRole != null) then (
		accountRole.OrgName:= POrgName;
		accountRole.ParentOrgName:= "Powrs";
		
		Waher.Persistence.Database.Update(accountRole);
		
		if(accountRole.UserName != accountRole.CreatorUserName) then (
			try (
				MailBody := Create(System.Text.StringBuilder);
				MailBody.Append("Hello,");
				MailBody.Append("<br />");
				MailBody.Append("<br />A subuser <strong>{{subUser}}</strong> has applyed for Legal Identity.");
				MailBody.Append("<br />Please review this request.");
				MailBody.Append("<br />");
				MailBody.Append("<br />Best regards");
				MailBody.Append("<br />Vaulter");
				
				MailBody := Replace(MailBody, "{{subUser}}", SessionUser.username);
				
				ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
				Config := ConfigClass.Instance;
				aMLMailRecipients := GetSetting("POWRS.PaymentLink.AMLContactEmail","");
				
				POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.Sender, Config.UserName, Config.Password, aMLMailRecipients, "Vaulter", MailBody, null, null);
	            destroy(MailBody);
			)
			catch(
				Log.Error("Error while sending email: " + Exception.Message, logObjectID, logActor, logEventID, null);
			);
		);
	);
)
catch
(
	Log.Error("Unable to apply for legal id: " + Exception.Message, logObjectID, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
         BadRequest(errors);
    )
    else 
    (
         BadRequest(Exception.Message);
    );
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
