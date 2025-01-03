SessionUser := Global.ValidateSmartAdminApiToken();

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
	
	endpointStart := Now;
	start := Now;
	CompletedPayspotPayments := 
		Select distinct TokenId, PaymentType, RefundedAmount, SenderFee
		from PayspotPayments
		where Result = "00"
			and DateCompleted >= DTDateFrom
			and DateCompleted < DTDateTo;
			
	Log.Debug("select from PayspotPayments -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
		
	start := Now;
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
	Log.Debug("payspotPaymentDictionary created -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
	
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
	
	tokens := Create(System.Collections.Generic.List, System.Object);
	users := Create(System.Collections.Generic.List, System.String);
	newPartners := 0;
	
	if(SessionUser.role == POWRS.PaymentLink.Models.AccountRole.SuperAdmin.ToString())then
	(
		start := Now;
		neuroFeatureTokenList := 
			select TokenId, Value
			from NeuroFeatureReferences
			where Updated >= DTDateFrom
				and Updated < DTDateTo;
		
		Log.Debug("SUPER ADMIN - select from NeuroFeatureReferences -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
		
		start := Now;
		foreach token in neuroFeatureTokenList do 
		(
			tokens.Add({
				TokenId: token[0],
				Value: token[1]
			});
		);
		Log.Debug("SUPER ADMIN - token list created -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
		
		start := Now;
		newPartners := 
			select count(*) 
			from LegalIdentities 
			where State = "Approved" 
				and Created >= DTDateFrom
				and Created < DTDateTo;	
		Log.Debug("select newPartners -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
	)
	else
	(
		start := Now;
		myOrganizations := POWRS.PaymentLink.Module.PaymentLinkModule.GetUsernameOrganizations(SessionUser.username);
		foreach org in myOrganizations do
		(
			users := Global.GetUsersForOrganization(org, true);
			foreach user in users do
			(
				neuroFeatureTokenList := 
				select TokenId, Value
				from NeuroFeatureReferences
				where Updated >= DTDateFrom
					and Updated < DTDateTo
					and OwnerJid = user;
					
				foreach token in neuroFeatureTokenList do 
				(
					tokens.Add({
						TokenId: token[0],
						Value: token[1]
					});
				);
				
				userName := Split(user, "@");
				legalID := select top 1 * from where State = "Approved" and Created >= DTDateFrom and Created < DTDateTo Account = userName;
				if(legalID != null)then(newPartners++);
			);			
		);
		Log.Debug("GROUP ADMIN - token list created and new partners selected -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
		
	);
			
	start := Now;
	foreach token in tokens do 
	(
	    if (payspotPaymentDictionary.ContainsKey(token.TokenId)) then 
		(			
			successfulTransactionsCount ++;
			successfulTransactionsValue += token.Value;
			
			obj := payspotPaymentDictionary[token.TokenId];
			if(obj.PaymentType == CardPayment) then 
			(
				cardSuccessCount ++;
				cardSuccessValue += token.Value;
				cardMarkUpFee += obj.SenderFee ?? 0;
			)
			else if(obj.PaymentType == IPSPayment)then 
			(
				ipsSuccessCount ++;
				ipsSuccessValue += token.Value;
				IPSFee += obj.SenderFee ?? 0;
			);
		)
		else
		(
			failedlTransactionsCount ++;
        );
	);
	Log.Debug("main calculation done -> time: " + (Now - start).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
	Destroy(neuroFeatureTokenList);
	Destroy(payspotPaymentDictionary);
		
	ReponseDict := Create(System.Collections.Generic.Dictionary, CaseInsensitiveString, System.Object);
	ReponseDict.Add("successfulTransactionsValue", successfulTransactionsValue);
	ReponseDict.Add("successfulTransactionsCount", successfulTransactionsCount);
	ReponseDict.Add("failedlTransactionsCount", failedlTransactionsCount);
	ReponseDict.Add("successfulTransactionsAverageValue", successfulTransactionsValue/successfulTransactionsCount);
	ReponseDict.Add("newPartners", newPartners);
	ReponseDict.Add("cardMarkUpFee", cardMarkUpFee);
	ReponseDict.Add("IPSFee", IPSFee);
	if(SessionUser.role == POWRS.PaymentLink.Models.AccountRole.SuperAdmin.ToString())then
	(
		ReponseDict.Add("holdFee", 0);
	);
	
	ReponseDict.Add("shareOfCompleted", Int(successfulTransactionsCount / (successfulTransactionsCount + failedlTransactionsCount) * 100));
	ReponseDict.Add("shareOfCard", Int(cardSuccessCount / successfulTransactionsCount * 100));
	ReponseDict.Add("shareOfIPS", Int(ipsSuccessCount / successfulTransactionsCount * 100));
	ReponseDict.Add("shareOfHold", 0);
	
	Destroy(newPartners);
	Log.Debug("whole endpoint done in -> time: " + (Now - endpointStart).get_Milliseconds() + " ms", logObject, logActor, logEventID, null);
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);
