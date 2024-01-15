Response.SetHeader("Access-Control-Allow-Origin","*");

SessionUser:= Global.ValidateAgentApiToken(false, false);

 {
  "authenticated": true,
  "isApproved": SessionUser.isApproved,
  "contactInformationsPopulated": SessionUser.contactInformationsPopulated
 }