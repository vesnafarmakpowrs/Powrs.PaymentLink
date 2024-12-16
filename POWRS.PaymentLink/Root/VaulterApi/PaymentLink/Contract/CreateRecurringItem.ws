
Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency)),
    "description":Required(String(PDescription)),
    "paymentDeadline": Required(String(PPaymentDeadline)),
	"deliveryDate": Required(Str(PDeliverAddress)),
	"totalNumberOfPayments": Required(Num(PNumberOfPayments)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)),
    "buyerAddress": Required(Str(PBuyerAddress)),
    "buyerCity": Optional(Str(PBuyerCity)) ,
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "successUrl":Optional(String(PSuccessUrl)),
    "errorUrl":Optional(String(PErrorUrl))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateRecurringItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

Global.["CreateRecurringItem"]:= (CreateRecurringItem(ValidatedUser, OrderNum, 
                                    Title, Price, Currency, 
									Description, PaymentDeadline, DeliveryDate, TotalNumberOfPayments,
                                    BuyerFirstName, BuyerLastName, BuyerEmail, BuyerPhoneNumber,
									BuyerAddress , BuyerCity, BuyerCountryCode, 
									CallBackUrl, SuccessUrl, ErrorUrl, LogActor)):=
(
   try
	(				 
        logEventID := "CreateRecurringItem.config";
		logObject := ValidatedUser.username;
		
		Password:= select top 1 Password from BrokerAccounts where UserName = ValidatedUser.username;
		
		errors:= Create(System.Collections.Generic.List, System.String);								
        if(Global.RegexValidation(OrderNum, "OrderNumber", "") == false) then 
        (
			errors.Add("orderNum");
		);
        if(Global.RegexValidation(Title, "OrderTitle", "") == false) then
		(
			errors.Add("title");
		);
		if(Global.RegexValidation(Currency, "Currency", "") == false) then 
		(
			errors.Add("currency");
		);
		if(Global.RegexValidation(Description, "OrderDescription", "") == false) then
		(
			errors.Add("description");
		);
		if(Global.RegexValidation(PaymentDeadline, "DateDDMMYYYY", "") == false) then 
		(
			errors.Add("paymentDeadline");
		);
		if(Global.RegexValidation(DeliveryDate, "DateDDMMYYYY", "") == false) then 
		(
			errors.Add("deliveryDate");
		);
		if(TotalNumberOfPayments < 1 or TotalNumberOfPayments > 36) then 
		(
			errors.Add("totalNumberOfPayments");
		);
		if(Global.RegexValidation(BuyerFirstName, "OrderBuyerFirsLastName", "") == false) then 
		(
			errors.Add("buyerFirstName");
		);

		if(Global.RegexValidation(BuyerLastName, "OrderBuyerFirsLastName", "") == false) then
		(
			errors.Add("buyerLastName");
		);
		if(Global.RegexValidation(BuyerEmail, "Email", "") == false) then 
		(
			errors.Add("buyerEmail");
		);
		
		if(exists(BuyerPhoneNumber)) then
		(
			if(System.String.IsNullOrWhiteSpace(BuyerPhoneNumber) or Global.RegexValidation(BuyerPhoneNumber, "PhoneNumber", "") == false) then 
			(
				errors.Add("buyerPhoneNumber");
			);
		)
		else
		(
			 BuyerPhoneNumber := "";
		);
		
		if(Global.RegexValidation(BuyerAddress, "Address", "") == false) then 
		(
			errors.Add("buyerAddress");
		);
		 
		if (!exists(BuyerCity)) then BuyerCity := "";

		if (Global.RegexValidation(BuyerCity, "OrderCity", "") == false) then 
		(
			errors.Add("buyerCity");
		);

		if(Global.RegexValidation(BuyerCountryCode, "CountryCode", "") == false) then 
		(
			errors.Add("buyerCountry");
		);
		
		if(!System.String.IsNullOrEmpty(SuccessUrl)) then
		(
			if(!ValidateUrl(SuccessUrl)) then 
			(
				errors.Add("SuccessUrl");
			);
		);
		
		if(!System.String.IsNullOrEmpty(ErrorUrl)) then
		(
			if(!ValidateUrl(ErrorUrl)) then 
			(
				errors.Add("ErrorUrl");
			);
		);

        dateTemplate:= "dd/MM/yyyy HH:mm:ss";
		PaymentDeadline += " 23:59:59";
		ParsedDeadlineDate:= System.DateTime.ParseExact(PaymentDeadline, dateTemplate, System.Globalization.CultureInfo.CurrentUICulture).ToUniversalTime();
		if(ParsedDeadlineDate < NowUtc) then
		(
			errors.Add("paymentDeadline");
		);

		DeliveryDate += " 23:59:59";
		ParsedDeliveryDate:= System.DateTime.ParseExact(DeliveryDate, dateTemplate, System.Globalization.CultureInfo.CurrentUICulture).ToUniversalTime();
		if(ParsedDeliveryDate < PaymentDeadline) then
		(
			errors.Add("DeliveryDate");
		);

		if(errors.Count > 0)then
		(
		   Error(errors);
	    );

		KeyId := GetSetting(ValidatedUser.username + ".KeyId","");
		KeyPassword:= GetSetting(ValidatedUser.username + ".KeySecret","");
							
		if(System.String.IsNullOrEmpty(KeyId) or System.String.IsNullOrEmpty(KeyPassword)) then 
		(
			Error("No signing keys or password available for user: " + ValidatedUser.username );
		);
		TemplateId:= GetSetting("POWRS.PaymentLink.RecurrenceTemplateId", ""); 

		if(System.String.IsNullOrWhiteSpace(TemplateId)) then 
		(
			Error("Not configured correctly");
		);

        Identity := select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = ValidatedUser.username And State = 'Approved';
		AgentName := Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST;
		if (System.String.IsNullOrEmpty(Identity.ORGBANKNUM)) then 
		(
			Error("Legal identity for this " + ValidatedUser.username + " mising bank account number");
		);
       	 
		Contract:=CreateContract(ValidatedUser.username, TemplateId, "Public",
		{
			"RemoteId": OrderNum,
			"Title": Title,
			"Description": Description,
			"Value": Price,
			"PaymentDeadline" : ParsedDeadlineDate,
			"DeliveryDate": ParsedDeliveryDate,
			"TotalNumberOfPayments": TotalNumberOfPayments,
			"DayOfMonth": ParsedDeliveryDate.Day,
			"Currency": Currency,
			"Country": BuyerCountryCode,
			"Expires": TodayUtc.AddYears(10),
			"SellerBankAccount" : Identity.ORGBANKNUM,
			"SellerName" : ((!System.String.IsNullOrEmpty(Identity.ORGNAME))? Identity.ORGNAME : AgentName),
			"BuyerFullName": BuyerFirstName + " " + BuyerLastName,
			"BuyerPhoneNumber": BuyerPhoneNumber,
			"BuyerEmail": BuyerEmail,
			"BuyerAddress": BuyerAddress,
			"BuyerCity" : BuyerCity,
			"CallBackUrl" : CallBackUrl,
			"SuccessUrl": SuccessUrl,
			"ErrorUrl": ErrorUrl
		});
		
		Nonce := Base64Encode(RandomBytes(32));

		LocalName := "ed448";
		Namespace := "urn:ieee:iot:e2e:1.0";

		S1 := ValidatedUser.username + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
		KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));
		
		S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + ValidatedUser.legalId + ":" + Contract.ContractId + ":" + "Creator";
        RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(Password)));
        
		POST("https://" + Waher.IoTGateway.Gateway.Domain + "/Agent/Legal/SignContract",
                 {
					"keyId": KeyId,
					"legalId": ValidatedUser.legalId,
					"contractId": Contract.ContractId,
					"role": "Creator",
					"nonce": Nonce,
					"keySignature": KeySignature,
					"requestSignature": RequestSignature
                 },
				{
					"Accept" : "application/json",
					"Authorization": "Bearer " + ValidatedUser.jwt
                });
				
		ContractSigned:= false;
		Counter:= 0;
		while ContractSigned == false and Counter < 10 do 
		(
		 State:= select top 1 State from Contracts where ContractId = Contract.ContractId;
		 ContractSigned:= State == "Signed";
		  
		 Counter += 1;
		 Sleep(1000);
		);
		
		TokenId:= select top 1 TokenId from IoTBroker.NeuroFeatures.Token where OwnershipContract = Contract.ContractId;
		
		{
			"ContractId" : Contract.ContractId,
			"TokenId" : TokenId,
			"BuyerEmail": BuyerEmail,
			"BuyerPhoneNumber": BuyerPhoneNumber,
			"Currency": Currency
		}
		
	)
	catch
	(
	    Log.Error(Exception.Message, logObject, LogActor, logEventID, null);
		if(errors.Count > 0) then 
		(
			Error(errors);
		)
		else 
		(
			Error(Exception.Message);
		);
		
	)
	finally
	(
		Destroy(logEventID);
		Destroy(logObject);
		Destroy(dateTemplate);
		Destroy(PaymentDeadline);
		Destroy(ParsedDeadlineDate);
		Destroy(KeyId);
		Destroy(KeyPassword);
		Destroy(ContractParameters);
		Destroy(EscrowFee);
		Destroy(Identity);
		Destroy(AgentName);
		Destroy(Nonce);
		Destroy(LocalName);
		Destroy(Namespace);
		Destroy(S1);
		Destroy(KeySignature);
		Destroy(ContractId);
		Destroy(Role);
		Destroy(S2);
		Destroy(RequestSignature);					
	);		    
);

try
(
    ContractInfo := Global.CreateRecurringItem(SessionUser, PRemoteId,
                PTitle, PPrice, PCurrency, 
                PDescription, PPaymentDeadline, PNumberOfPayments,
			    PBuyerFirstName, PBuyerLastName, PBuyerEmail, PBuyerPhoneNumber ??? "",
			    PBuyerAddress , PBuyerCity ?? "", PBuyerCountryCode, 
			    PCallBackUrl ?? "", PSuccessUrl ?? "", PErrorUrl ?? "",
			    logActor);
			
    PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");
    
    {
        "Link" : PaymentLinkAddress + "/"Authorize.md"" + PayoutPage + "?ID=" + Global.EncodeContractId(ContractInfo.ContractId),	
        "TokenId" : ContractInfo.TokenId,
        "BuyerEmail": ContractInfo.BuyerEmail,
        "BuyerPhoneNumber": ContractInfo.BuyerPhoneNumber,
        "Currency": ContractInfo.Currency
    }

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
