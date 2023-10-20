({
    "jwt":Required(Str(PJwt)),
    "includeInfo":Optional(Bool(PIncludeInfo))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

reason:= null;
username:= null;
jwtFactory:= null;
returnUserInfo:= false;
Waher.Runtime.Inventory.Types.TryGetModuleParameter("JWT", jwtFactory);

if(exists(PIncludeInfo)) then 
(
 returnUserInfo:= PIncludeInfo;
);

if(jwtFactory == null) then 
(
 Forbidden("Forbidden");
);

Token:= null;

try 
(
 Token:=Create(JwtToken, PJwt);
)
catch
(
 BadRequest("Invalid token");
);

if(!jwtFactory.IsValid(Token, reason)) then 
(
 Forbidden("Token " + reason);
);

array:= Split(Token.Claims.sub, "@");
if(array.Length != 2) then 
(
 BadRequest("Invalid token");
);

username:= Trim(array[0]);
userDomain:= Trim(array[1]);
gatewayDomain:= Trim(Gateway.Domain);

if(System.String.IsNullOrWhiteSpace(username) || System.String.IsNullOrWhiteSpace(domain) || !userDomain.Equals(gatewayDomain, StringComparison.InvariantCultureIgnoreCase)) then 
(
 BadRequest("Invalid user");
);

legalIdentity:= select top 1 Id from LegalIdentities where Account = username and State = "Approved";

if(System.String.IsNullOrWhiteSpace(legalIdentity)) then 
(
 Forbidden("User is not approved");
);

id:= returnUserInfo ? legalIdentity : "";
user:= returnUserInfo ? username : "";

if(returnUserInfo) then 
(
 {
  "authenticated": true,
  "legalId": id,
  "userName": username
}
)
else
(
 {
  "authenticated": true
 }
);