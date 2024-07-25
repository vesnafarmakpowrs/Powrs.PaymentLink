Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true,false);

logObjectID := SessionUser.username;
logEventID := "PaySpotTransactions.ws";
logActor := Request.RemoteEndPoint.Split(':', null)[0];


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
  OrderList := Select TokenId, OrderId, OrderReference, PayspotTransactionId, DateCreated, ExpectedPayoutDate, PayoutDate, Amount,  SenderFee  
				from PayspotPayments 
			    where DateCreated >= DTDateFrom and DateCreated <= DTDateTo and Result='00';


  ReponseDict := Create(System.Collections.Generic.List, System.Object);
  foreach order in OrderList do (
	       OrderCreatorLegalId := select top 1 Creator
				                 	from IoTBroker.NeuroFeatures.Token 
					                where TokenId = order[0];
           SellerAccount :=  select top 1 Account from LegalIdentities where Id=OrderCreatorLegalId;
           fee := order[8] == null ? 0 : Double(order[8]);
           ReponseDict.Add({
						"TokenId": order[0],
						"OrderId": order[1],
						"OrderReference": order[2],
						"PayspotTransactionId": order[3],
						"DateCreated": order[4],
						"ExpectedPayoutDate": order[5],
						 "PayoutDate" :  order[6],
						"Amount": order[7],
						"SenderFee": fee,
						"SellerRecivedAmount" : Dbl(order[7])-fee,
						"Seller" :  SellerAccount
					});		
         );
)
catch
(
	Log.Error(Exception.Message, logObjectID, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);