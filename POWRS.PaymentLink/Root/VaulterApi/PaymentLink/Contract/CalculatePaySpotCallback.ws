Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");


SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CalculatePaySpotCallback.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(

Timestamp := GetElement(Posted,"Timestamp");
Result := GetElement(Posted,"Result");
MAC := GetElement(Posted,"MAC");
Data := GetElement(Posted,"Data");

if (InnerText(Result) == "00") then
(

AuthorizationRequest := GetElement(Data,"AuthorizationRequest");
Header := GetElement(AuthorizationRequest,"Header");

ShopId :=  GetElement(Header,"ShopID");


OrderId := GetElement(AuthorizationRequest,"OrderID");
Amount := GetElement(AuthorizationRequest,"Amount");
Currency := GetElement(AuthorizationRequest,"Currency");

{
   "ShopId": InnerText(ShopId),
   "OrderId": InnerText(OrderId),
   "transactionStatus": "01" ,
   "transactionResult":InnerText(Result),
   "transactionAmount": InnerText(Amount),
   "authorizedAmount": InnerText(Amount),
   "accountedAmount": InnerText(Amount),
   "refundedAmount": "0",
   "currency": InnerText(Currency),
   "authorizationNumber":"A93485",
   "transactionDate":null,
   "result": InnerText(Result),
   "resultDescription":null
}
)
else
(

{
   "transactionResult":InnerText(Result),
   "Invalid request" : "Invalid request"
}
)

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
        BadRequest(Exception.Message);
);
