Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");


SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CalculatePaySpotCallback.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	Timestamp := GetElement(Posted,"Timestamp");
	Result := InnerText(GetElement(Posted,"Result"));
	MAC := GetElement(Posted,"MAC");
	Data := GetElement(Posted,"Data");

	if (Result == "00") then
	(
		AuthorizationRequest := GetElement(Data,"AuthorizationRequest");
		Authorization := GetElement(Data,"Authorization");
		Header := GetElement(AuthorizationRequest,"Header");

		ShopId :=  GetElement(Header,"ShopID");

		OrderId := InnerText(GetElement(Authorization,"OrderId"));
		Amount := GetElement(AuthorizationRequest,"Amount");
		Currency := GetElement(AuthorizationRequest,"Currency");
		TransactionId := InnerText(GetElement(Authorization,"TransactionID"));
		AuthorizationNumber := InnerText(GetElement(Authorization,"AuthorizationNumber"));
		TransactionStatus := GetElement(Authorization, "TransactionStatus");
		TransactionResult := GetElement(Authorization, "TransactionResult");
		RefundedAmount := GetElement(Authorization, "RefundedAmount");
		
		CompanyId:= GetSetting("POWRS.Payment.PaySpot.CompanyId","");
		PSecretKey := GetSetting("POWRS.Payment.PaySpot.SecretKey","");
		RandomNum := Base64Encode(RandomBytes(32));
		PlainText := RandomNum + "|" + CompanyId + "|" + TransactionId + "|" + PSecretKey;
		Hash := Sha2_512(PlainText);
		
		CallBackRequestData := {
			"companyID": CompanyId,
			"rnd": RandomNum,
			"hash": Hash,
			"authorization": 
				{
				   "TransactionID" : TransactionId,
				   "ShopId": InnerText(ShopId),
				   "OrderId": OrderId,
				   "transactionStatus": InnerText(TransactionStatus) ,
				   "transactionResult":InnerText(TransactionResult),
				   "transactionAmount": InnerText(Amount),
				   "authorizedAmount": InnerText(Amount),
				   "accountedAmount": InnerText(Amount),
				   "refundedAmount": InnerText(RefundedAmount),
				   "currency": InnerText(Currency),
				   "authorizationNumber": AuthorizationNumber,
				   "transactionDate":null,
				   "result": Result,
				   "resultDescription":null
			   }
		};
		
			domain:= "https://" + Gateway.Domain;
			namespace:= domain + "/Downloads/EscrowPaylinkRS.xsd";
			xmlText := "<PayspotPaymentCompleted xmlns=\"" + namespace + "\" payspotOrderId=\"\"  orderId=\"" + OrderId + "\" paymentType=\"PaymentCard\"" + " TransactionId=\"" + TransactionId +  "\" AuthNumber=\"" + AuthorizationNumber + "\" />";
			 Log.Debug(xmlText, logObject, logActor, logEventID, null);
			xmlNote := Xml(xmlText);
			
			TokenId := select top 1 TokenId from PayspotPayments where OrderId = OrderId;
			
			Update PayspotPayments set Result='00',  AuthNumber=AuthorizationNumber, TransactionId=TransactionId   where OrderId=OrderId;
			
			if (TokenId != null) then
			(
			    Log.Debug(SessionUser.jwt, logObject, logActor, logEventID, null);
				 Log.Debug("TokenId:"+  TokenId, logObject, logActor, logEventID, null);
				xmlNoteResponse := POST(domain + ":8088/AddNote/" + TokenId, xmlNote, {}, Waher.IoTGateway.Gateway.Certificate);
			);
		
		config:= POWRS.Payment.PaySpot.ServiceConfiguration.GetCurrent();
        isProduction:= config.IsProduction ?? false;
        paySpotCallBackURL := isProduction ? "https://www.nsgway.rs:50010/api/ecommerce/AuthorizationCallback"  : "https://test.nsgway.rs:50009/api/ecommerce/AuthorizationCallback";
		
	    PaySpotCallbackResponse := Post(paySpotCallBackURL, CallBackRequestData, {"Accept" : "application/json"});
			
		{
		   "Ok"
	    }
		
	)
	else
	(
	    {
		   "transactionResult": InnerText(Result),
		   "Invalid request" : "Invalid request"
		}
	);

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
