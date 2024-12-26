Response.SetHeader("Access-Control-Allow-Origin","*");

SessionUser:= Global.ValidateSmartAdminApiToken();

{
	"authenticated": true,
	"orgName": SessionUser.orgName,
	"role": SessionUser.role
}