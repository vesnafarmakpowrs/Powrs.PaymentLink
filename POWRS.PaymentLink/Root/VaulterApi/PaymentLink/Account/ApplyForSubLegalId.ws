({
    "FIRST": Required(Str(PFirstName)),
    "LAST": Required(Str(PLastName)),
    "PNR": Required(Str(PPersonalNumber) ),
    "COUNTRY": Required(Str(PCountryCode))
}:=Posted) ??? BadRequest("Request does not conform to the specification");

SessionUser:= Global.ValidateAgentApiToken(false, false);  
try
(
	Password := 
		select top 1 Password 
		from BrokerAccounts 
		where UserName = SessionUser.username;
			
	if(System.String.IsNullOrWhiteSpace(Password)) then 
	(
		Error("No user with given username");
	);

	errors:= Create(System.Collections.Generic.List, System.String);

	if(PFirstName not like "[\\p{L}\\s]{2,30}") then 
	(
		errors.Add("FIRST");    
	);
	if(PLastName not like "[\\p{L}\\s]{2,30}") then 
	(
		errors.Add("LAST");
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

	if(errors.Count > 0) then
	(
		Error(errors);
	);

	existingLegalIdentity := 
		select top 1 Id 
		from LegalIdentities 
		where Account = SessionUser.username
			and State = "Approved";
		
	if(!System.String.IsNullOrEmpty(existingLegalIdentity)) then 
	(
		Error("Approved legal identity for account already exists: " + SessionUser.username);
	);

	objBrokerAccountRole := 
		select top 1 * 
		from POWRS.PaymentLink.Models.BrokerAccountRole 
		where UserName = SessionUser.username;

	if(objBrokerAccountRole == null) then (
		Error("No broker account role found for user: " + SessionUser.username);
	);

	if(System.String.IsNullOrEmpty(objBrokerAccountRole.CreatorUserName)) then 
	(
		Error("No parent account found for user: " + SessionUser.username);
	);

	parentLegalIdentity:= 
		select top 1 * 
		from IoTBroker.Legal.Identity.LegalIdentity 
		where Account = objBrokerAccountRole.CreatorUserName 
			and State = "Approved" 
		order by Created desc;

	if(parentLegalIdentity == null) then 
	(
		Error("Parent does not have approved legalIdentity");
	);

	dictionary:= {};

	dictionary["FIRST"]:= PFirstName;
	dictionary["LAST"]:= PLastName;
	dictionary["PNR"]:= PPersonalNumber;
	dictionary["COUNTRY"]:= PCountryCode;

	foreach property in parentLegalIdentity.Properties do
	(
		if(property.Name != "FIRST" and 
			property.Name != "LAST" and 
			property.Name != "PNR" and 
			property.Name != "COUNTRY" and 
			property.Name != "JID" and 
			property.Name != "EMAIL" and
			property.Name != "AGENT") then
		(
			dictionary[property.Name]:= property.Value;
		);
	);

	PropertiesVector := [FOREACH prop IN dictionary: {name: prop.Key, value: prop.Value}];

	Global.ApplyForAgentLegalId(SessionUser, Password, PropertiesVector);
)
catch
(
	Log.Error(Exception.Message, null);
	BadRequest(Exception.Message);
);

Return("ok");