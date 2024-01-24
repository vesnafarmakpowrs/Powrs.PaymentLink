Response.SetHeader("Access-Control-Allow-Origin","*");

try
(
ValidatedUser:= Global.ValidateAgentApiToken(false, false);
if(System.String.IsNullOrEmpty(ValidatedUser.legalId)) then 
(
	Identity := select top 1 Properties from LegalIdentities where Account = ValidatedUser.username and State = "Created" order by Created desc;
)
else
(
	Identity := select top 1 Properties from LegalIdentities where Id = ValidatedUser.legalId;
);

IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);

if(Identity != null) then 
(
	foreach Parameter in Identity do 
	(
		Parameter.Value != null ? IdentityProperties.Add(Parameter.Name, Parameter.Value);
	);
);
 {
  "Properties": IdentityProperties,
  "HasApplied": IdentityProperties.Count > 0
 }

)
catch
(
    Log.Error(Exception, null);
	BadRequest(Exception.Message);
);
