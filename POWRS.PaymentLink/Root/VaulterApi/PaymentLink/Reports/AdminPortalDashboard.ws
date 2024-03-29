ValidatedUser := Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"DaysToCalculate":Required(Integer(PDaysToCalculate))
}:=Posted) ??? BadRequest(Exception.Message);

try(
	
	TotalFeeEarned:= 0;
	
	LimitDate := System.DateTime.Now.Date.AddDays(PDaysToCalculate == 1 ? 0 : -PDaysToCalculate);

	CardPayment :=  "PaymentCard";
        IPSPayment :=  "IPSPayment";
	CompletedPayspotPayments := 
		Select distinct TokenId, PaymentType
		from PayspotPayments
		where Result = "00"
		   and DateCompleted >= LimitDate;
		
	PayspotPaymentDictionary := Create(System.Collections.Generic.Dictionary,System.String,System.String);
	foreach p in CompletedPayspotPayments do 
	    PayspotPaymentDictionary.Add(p[0],p[1]);
	

	NeuroFeatureTokenList  := 
		select  *  from IoTBroker.NeuroFeatures.Token
		where Created >= LimitDate;
			
	TokenId := "";
	MachineId := "";
	
	trn_SuccessCnt := 0;
	trn_SuccessValue := 0;
	trn_Currency := "";
	trn_FailedCnt := 0;
	ipsSuccessValue := 0;
        cardSuccessValue := 0;

	foreach token in NeuroFeatureTokenList do (
		
		   if (PayspotPaymentDictionary.ContainsKey(token.TokenId)) then (
		    escrowFeeVariable := Select top 1 Value from token.GetCurrentStateVariables().VariableValues where Name="EscrowFee";
		
			if(escrowFeeVariable != null) then 
				TotalFeeEarned += escrowFeeVariable;
			
			trn_SuccessCnt ++;
			trn_SuccessValue += token.Value;
			trn_Currency := token.Currency ;
			
			PaymentType := PayspotPaymentDictionary[token.TokenId];
                        PaymentType == CardPayment  ? cardSuccessValue += token.Value;
                        PaymentType == IPSPayment  ? ipsSuccessValue +=  token.Value;
		)  else (
                       trn_FailedCnt ++;
                );
	);

	cardMarkUp_Fee := cardSuccessValue * 0.002;
	IPS_Fee := ipsSuccessValue * 0.002;
	
        ReponseDict := Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
	ReponseDict.Add("trn_TotalValue:" + trn_Currency, String(trn_SuccessValue));
	ReponseDict.Add("trn_TotalSuccess" , String(trn_SuccessCnt));
	ReponseDict.Add("trn_TotalFailed", String(trn_FailedCnt));
	ReponseDict.Add("trn_TotalFee", String(TotalFeeEarned));
	ReponseDict.Add("cardMarkUp_Fee", String(cardMarkUp_Fee));
	ReponseDict.Add("IPS_Fee", String(IPS_Fee));
)
catch(
	Log.Error(Exception, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);
