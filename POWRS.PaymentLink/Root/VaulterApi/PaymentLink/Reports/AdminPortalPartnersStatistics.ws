SessionUser := Global.ValidateAgentApiToken(false, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"from":Required(String(PDateFrom)),
    "to":Required(String(PDateTo)),
	"organizationList": Required(String(POrganizationList)),
	"topicFilterType": Required(String(PTopicFilterType)),
	"topicFilterCondition": Required(String(PTopicFilterCondition)),
	"topicFilterNumber": Required(Int(PTopicFilterNumber))	
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "AdminPortalDashboard.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

currentMethod := "";
errors:= Create(System.Collections.Generic.List, System.String);

ValidatePostedData(Posted) := (
	if(!Global.RegexValidation(Posted.from, "DateDDMMYYYY", "")) then
	(
		errors.Add("from");
	);
	if(!Global.RegexValidation(Posted.to, "DateDDMMYYYY", "")) then
	(
		errors.Add("to");
	);
	if(!System.String.IsNullOrWhiteSpace(Posted.organizationList))then
	(
		myOrganizations := POWRS.PaymentLink.Models.BrokerAccountRole.GetAllOrganizationChildren(SessionUser.orgName);
		organizationArray := Split(Posted.organizationList, ",");
		foreach item in organizationArray do
		(
			if(myOrganizations.Contains(item) == false) then
			(
				errors.Add("organizationName:" + item);
			);
		);
	);
	
	if(!Enum.IsDefined(typeof(POWRS.PaymentLink.Utils.Enums.Reports.TopicFilter), Posted.topicFilterType))then
	(
		errors.Add("topicFilterType");
	);
	if(!Enum.IsDefined(typeof(POWRS.PaymentLink.Utils.Enums.Reports.TopicFilterCondition), Posted.topicFilterCondition))then
	(
		errors.Add("topicFilterCondition");
	);
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);
	
	return (1); 
);

try
(
	' PaylinksCount
	' AveragePaylinkValue
	' LastPaylink DateTime
	' PaylinkFrequency -> prosecan broj dana izmedju linkova
	
	' Onboarding Started Date
	' Onboarding Last Activity (ako je zavrseno onboarding onda ide 0)
	' Onboarding completed DateTime (datum odobravanja LegalId)



	Log.Debug("Posted: " + Str(Posted), logObject, logActor, logEventID, null);
	
	currentMethod := "ValidatePostedData";
	ValidatePostedData(Posted);
	
	
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
		
	PayspotPaymentDictionary := Create(System.Collections.Generic.Dictionary, System.String, System.Object);
	foreach payment in CompletedPayspotPayments do
	(
		if(payment[2] == null or payment[2] == 0) then
		(
			obj := {
				TokenId: payment[0],
				PaymentType: payment[1],
				RefundedAmount: payment[2],
				SenderFee: payment[3]
			};
		
			PayspotPaymentDictionary.Add(payment[0], obj);
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
	
	NeuroFeatureTokenList  := 
		select * 
		from IoTBroker.NeuroFeatures.Token
		where Created >= DTDateFrom
			and Created < DTDateTo;
			
	foreach token in NeuroFeatureTokenList do 
	(
	    if (PayspotPaymentDictionary.ContainsKey(token.TokenId)) then 
		(			
			successfulTransactionsCount ++;
			successfulTransactionsValue += token.Value;
			
			obj := PayspotPaymentDictionary[token.TokenId];
			if(obj.PaymentType == CardPayment) then 
			(
				cardSuccessCount ++;
				cardSuccessValue += token.Value;
				cardMarkUpFee += obj.SenderFee ?? 0;
			)
			else if(obj.PaymentType == IPSPayment)then 
			(
				ipsSuccessCount ++;
				ipsSuccessValue +=  token.Value;
				IPSFee += obj.SenderFee ?? 0;
			);
		)
		else
		(
			failedlTransactionsCount ++;
        );
	);
	Destroy(NeuroFeatureTokenList);
	Destroy(PayspotPaymentDictionary);
	
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
	Log.Error("Unable to save onboarding data: " + Exception.Message + "\ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		NotAcceptable(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);

return (ReponseDict);
