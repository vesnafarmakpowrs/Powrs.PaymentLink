Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "CompanyID":Required(String(PCompanyID)),
    "TransactionID":Required(String(PTransactionId)),
    "SecretKey":Required(String(PSecretKey))
  
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CalculateHash.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    
RandomNum := Base64Encode(RandomBytes(32));
PlainText := RandomNum + "|" + PCompanyID + "|" + PTransactionId + "|" + PSecretKey;

Hash := Sha2_512(PlainText);


{
   "Random Number" : RandomNum ,
   "Plain Text" : PlainText ,
   "Hash" : Hash
}

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
