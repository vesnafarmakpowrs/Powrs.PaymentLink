Response.SetHeader("Access-Control-Allow-Origin","*");

SessionUser:= Global.ValidateAgentApiToken(false);

 {
  "authenticated": true,
  "isApproved": SessionUser.isApproved
 }