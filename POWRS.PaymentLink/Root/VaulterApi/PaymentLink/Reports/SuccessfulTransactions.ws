SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"DateFrom":Required(String(PDateFrom)),
	"DateTo":Required(String(PDateTo)),
	"PaymentType":Optional(String(PPaymentType)),
	"CardBrand":Optional(String(PCardBrand))
}:=Posted) ??? BadRequest(Exception.Message);

try(	
		
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, "yyyy-MM-dd", System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, "yyyy-MM-dd", System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);

       creatorJid:= SessionUser.username + "@" + Gateway.Domain;
      
       payspotPayment:=  Select TokenId, Amount , PaymentType , CardBrand 
			 from PayspotPayment
			 where DateCompleted >= DTDateFrom
			 and DateCompleted < DTDateTo;				
			
       paymentsByTypeList:= Create(System.Collections.Generic.List, System.Object);

	if exists(PPaymentType) then
			  foreach payment in payspotPayment do 
			  (
			    if payment[2] == PPaymentType then
				  paymentsByTypeList.Add({
				    "TokenId":payment[0],
					"Amount": payment[1],
					"PaymentType": payment[2],
					"CardBrand" : payment[3]
				  });	              
			  );
				
	paymentsByCardList:= Create(System.Collections.Generic.List, System.Object);

	if exists(PCardBrand) then
			  foreach payment in paymentsByTypeList do 
			  (
			    if payment.CardBrand == PCardBrand then
				  paymentsByCardList.Add({
				    "TokenId":payment.TokenId,
					"Amount": payment.Amount,
					"PaymentType": payment.PaymentType,
					"CardBrand" : payment.CardBrand
				  });	              
			  );

   
    resultList := payspotPayment;
    if exists(PCardBrand) then 
	resultList := paymentsByCardList
    else if exists(PPaymentType) then
	resultList := paymentsByTypeList;

    responseList:= Create(System.Collections.Generic.List, System.Object);

    foreach payment in resultList do 
     (
        token :=  select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId = payment.TokenId;
        variables:= token.GetCurrentStateVariables();

       RemoteId:= "";
       Currency := "";
       foreach variable in variables.VariableValues DO 
        (
             variable.Name == "RemoteId" ? RemoteId := variable.Value;
             variable.Name == "Currency" ? Currency := variable.Value;
        );

       responseList.Add({
			   "TokenId":payment.TokenId,
			   "Amount": payment.Amount,
			   "PaymentType": payment.PaymentType,
			   "CardBrand" : payment.CardBrand,
               "RemoteId" : RemoteId,
               "Currency" : Currency
		       });	              
     );

)
catch(
	Log.Error(Exception, null);
	InternalServerError(Exception.Message);
);

return(responseList);