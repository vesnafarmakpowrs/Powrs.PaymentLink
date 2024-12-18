SessionUser := Global.ValidateAgentApiToken(false, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "AdminPortalDashboard.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	if(Global.RegexValidation(PDateFrom, "DateDDMMYYYY", "") == false or Global.RegexValidation(PDateTo, "DateDDMMYYYY", "") == false) then
	(
		BadRequest("Date format must be dd/MM/yyyy");
	);
	
	dateFormat := "dd/MM/yyyy";
	DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
	DTDateTo := DTDateTo.AddDays(1);
	
	CardPayment :=  "PaymentCard";
	IPSPayment :=  "IPSPayment";
		
	CompletedPayspotPayments := 
		Select distinct TokenId, PaymentType, RefundedAmount, SenderFee
		from PayspotPayments
		where Result = "00"
			and DateCompleted >= DTDateFrom
			and DateCompleted < DTDateTo;
		
	payspotPaymentDictionary := Create(System.Collections.Generic.Dictionary, System.String, System.Object);
	foreach payment in CompletedPayspotPayments do
	(
		if(payment[2] == null or payment[2] == 0) then
		(
			if(!payspotPaymentDictionary.ContainsKey(payment[0]))then
			(
				obj := {
					TokenId: payment[0],
					PaymentType: payment[1],
					RefundedAmount: payment[2],
					SenderFee: payment[3]
				};
			
				payspotPaymentDictionary.Add(payment[0], obj);
			
			);
		);
	);
	
	Destroy(CompletedPayspotPayments);
				
	successfulTransactionsCount := 0;
	successfulTransactionsValue := 0;
	failedlTransactionsCount := 0;
	ipsSuccessCount := 0;
	ipsSuccessValue := 0;
	IPSFee := 0;	
	cardSuccessCount := 0;
	cardSuccessValue := 0;
	cardMarkUpFee := 0;
	
	neuroFeatureTokenList := 
		select TokenId, Value
		from NeuroFeatureReferences
		where Created >= DTDateFrom
			and Created < DTDateTo;
			
	foreach token in neuroFeatureTokenList do 
	(
	    if (payspotPaymentDictionary.ContainsKey(token[0])) then 
		(			
			successfulTransactionsCount ++;
			successfulTransactionsValue += token[1];
			
			obj := payspotPaymentDictionary[token[0]];
			if(obj.PaymentType == CardPayment) then 
			(
				cardSuccessCount ++;
				cardSuccessValue += token[1];
				cardMarkUpFee += obj.SenderFee ?? 0;
			)
			else if(obj.PaymentType == IPSPayment)then 
			(
				ipsSuccessCount ++;
				ipsSuccessValue +=  token[1];
				IPSFee += obj.SenderFee ?? 0;
			);
		)
		else
		(
			failedlTransactionsCount ++;
        );
	);
	Destroy(neuroFeatureTokenList);
	Destroy(payspotPaymentDictionary);
	
	newPartners := 
		select count(*) 
		from LegalIdentities 
		where State = "Approved" 
			and Created >= DTDateFrom
			and Created < DTDateTo;	
	
	ReponseDict := Create(System.Collections.Generic.Dictionary, CaseInsensitiveString, System.Object);
	ReponseDict.Add("successfulTransactionsValue", successfulTransactionsValue);
	ReponseDict.Add("successfulTransactionsCount", successfulTransactionsCount);
	ReponseDict.Add("failedlTransactionsCount", failedlTransactionsCount);
	ReponseDict.Add("successfulTransactionsAverageValue", successfulTransactionsValue/successfulTransactionsCount);
	ReponseDict.Add("newPartners", newPartners);
	ReponseDict.Add("cardMarkUpFee", cardMarkUpFee);
	ReponseDict.Add("IPSFee", IPSFee);
	ReponseDict.Add("holdFee", 0);
	
	ReponseDict.Add("shareOfCompleted", Int(successfulTransactionsCount / (successfulTransactionsCount + failedlTransactionsCount) * 100));
	ReponseDict.Add("shareOfCard", Int(cardSuccessCount / successfulTransactionsCount * 100));
	ReponseDict.Add("shareOfIPS", Int(ipsSuccessCount / successfulTransactionsCount * 100));
	ReponseDict.Add("shareOfHold", 0);
	
	Destroy(newPartners);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);
