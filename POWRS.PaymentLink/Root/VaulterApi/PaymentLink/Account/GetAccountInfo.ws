({
   
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

Jwt:= null;
auth := null;
try
(
header:= null;
Request.Header.TryGetHeaderField("Authorization", header);
Jwt:= header.Value;
auth:= POST("https://" + Gateway.Domain + "/VaulterApi/PaymentLink/VerifyToken.ws", 
            {"includeInfo": true}, {"Accept": "application/json", "Authorization": header.Value});
)
catch
(
  Forbidden("Token not valid");
);

LegalId := auth.legalId;
Identity := select top 1 Properties from LegalIdentities where Id = LegalId;
IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);

foreach Parameter in Identity do
  Parameter.Value != null ? IdentityProperties.Add(Parameter.Name, Parameter.Value);

Response.SetHeader("Access-Control-Allow-Origin","*");

IdentityProperties;