Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true,false);

logObjectID := SessionUser.username;
logEventID := "PaySpotTransactions.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];


({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$")
}:=Posted) ??? BadRequest(Exception.Message);
try
(

  dateFormat := "dd/MM/yyyy";
  DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
  DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
  DTDateTo := DTDateTo.AddDays(1);

  OrderList:= Select TokenId, OrderId, OrderReference, PayspotTransactionId, DateCreated, 
					 ExpectedPayoutDate, PayoutDate, Amount,SenderFee 
					 from PayspotPayments
					 where DateCreated >= DTDateFrom and DateCreated <= DTDateTo and Result='00';

ReponseDict := Create(System.Collections.Generic.List, System.Object);
  foreach order in OrderList do (
	   Token:= select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId = order[0];
	   Variables:= Token.GetCurrentStateVariables().VariableValues ??? null;

			if(Token != null and Variables != null) then 
			(
				SellerAccount :=  Split(Token.CreatorJid, "@")[0];
				RemoteId:= select top 1 Value from Variables where Name = "RemoteId";
				SmsCounter:= select top 1 Value from Variables where Name = "SMSCounter";
				EmailCounter:= select top 1 Value from Variables where Name = "EmailCounter";
				fee := order[8] == null ? 0 : Double(order[8]);
				amount:= order[7] == null ? 0 : order[7];

				ReponseDict.Add({
						"TokenId": order[0],
						"OrderId": order[1],
						"OrderReference": order[2],
						"PayspotTransactionId": order[3],
						"DateCreated": order[4],
						"ExpectedPayoutDate": order[5],
						"PayoutDate" :  order[6],
						"Amount": amount,
						"SenderFee": fee,
						"SellerRecivedAmount" : Dbl(amount)-fee,
						"Seller" :  SellerAccount,
						"RemoteId": RemoteId,
						"SMSCounter": SmsCounter, 
						"EmailCounter": EmailCounter
						});
				);	   
         );
)
catch
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);