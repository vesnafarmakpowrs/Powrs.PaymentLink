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
	
	Authorization := GetElement(Data,"Authorization");
	AuthorizationRequest := GetElement(Data,"AuthorizationRequest");
	Header := GetElement(AuthorizationRequest,"Header");
	ShopId :=  GetElement(Header,"ShopID");
	OrderId := InnerText(GetElement(AuthorizationRequest,"OrderID"));
	
	
    Amount := GetElement(AuthorizationRequest,"Amount");
	Currency := GetElement(AuthorizationRequest,"Currency");
	
	domain:= "https://" + Gateway.Domain;
	namespace:= domain + "/Downloads/EscrowPaylinkRS.xsd";
	
	TokenId := select top 1 TokenId from PayspotPayments where OrderId = OrderId;
		
	config:= POWRS.Payment.PaySpot.ServiceConfiguration.GetCurrent();
    isProduction:= config.IsProduction ?? false;
    paySpotCallBackURL := isProduction ? "https://www.nsgway.rs:50010/api/ecommerce/AuthorizationCallback"  : "https://test.nsgway.rs:50009/api/ecommerce/AuthorizationCallback";
	
	siaPaymentResult := CreateType(POWRS.Networking.PaySpot.Consants.BasePaymentResult, POWRS.Networking.PaySpot.Consants.SiaPaymentResult);
	resultDescription := siaPaymentResult.GetPropertyName(Result);
			
	if (Result == "00") then
	(
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
				   "resultDescription": resultDescription
			   }
		};
			
			xmlText := "<PayspotPaymentCompleted xmlns=\"" + namespace + "\" payspotOrderId=\"\"  orderId=\"" + OrderId + "\" paymentType=\"PaymentCard\"" + " TransactionId=\"" + TransactionId +  "\" AuthNumber=\"" + AuthorizationNumber + "\" />";
			xmlNote := Xml(xmlText);
		
			Update PayspotPayments set Result='00',  AuthNumber = AuthorizationNumber, BankTransactionId = TransactionId, ResultDescription = resultDescription  where OrderId=OrderId;
			
			if (TokenId != null) then
			(
				xmlNoteResponse := POST(domain + ":8088/AddNote/" + TokenId, xmlNote, {}, Waher.IoTGateway.Gateway.Certificate);
			);
		
	    PaySpotCallbackResponse := Post(paySpotCallBackURL, CallBackRequestData, {"Accept" : "application/json"});
			
		{
		   "Ok"
	    }
		
	)
	else
	(
		Res := Result.ToString();
	    Update PayspotPayments set Result = Res, ResultDescription = resultDescription   where OrderId=OrderId and  Result != '00';
		
		xmlText := "<PayspotPaymentStatus xmlns=\"" + namespace + "\" payspotOrderId=\"\"  orderId=\"" + OrderId + "\" paymentType=\"PaymentCard\"" + " paymentStatusCode=\"" + Res +  "\" paymentStatusDescr=\"" + resultDescription + "\" />";
		xmlNote := Xml(xmlText);
		if (TokenId != null) then
		(
			xmlNoteResponse := POST(domain + ":8088/AddNote/" + TokenId, xmlNote, {}, Waher.IoTGateway.Gateway.Certificate);
		);
		
	    {
		   "transactionResult": Result,
		   "Invalid request" : "Invalid request"
		}
	);

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
