try
(
ValidatedUser:= Global.ValidateAgentApiToken(true, false);

Identity := select top 1 Properties from LegalIdentities where Id = ValidatedUser.legalId;
IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);

foreach Parameter in Identity do 
(
	Parameter.Value != null ? IdentityProperties.Add(Parameter.Name, Parameter.Value);
);  

IdentityProperties;
)
catch
(
    Log.Error(Exception, null);
	BadRequest(Exception.Message);
);
