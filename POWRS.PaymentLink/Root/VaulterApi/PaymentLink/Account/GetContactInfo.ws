Response.SetHeader("Access-Control-Allow-Origin","*");

ValidatedUser:= Global.ValidateAgentApiToken(false, false);

try
(
	contactInfo:= select top 1 * from OrganizationContactInfo where Account = ValidatedUser.username;
)	
catch
(
	Log.Error(Exception, null);
	BadRequest(Exception.Message);
);
