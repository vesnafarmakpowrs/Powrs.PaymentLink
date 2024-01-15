﻿

ValidatedUser := Global.ValidateAgentApiToken(true);

if !exists(Posted) then BadRequest("No payload.");

({
	"DaysToCalculate":Required(Integer(PDaysToCalculate))
}:=Posted) ??? BadRequest(Exception.Message);

try(
	
	ReponseDict := Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
	LimitDate := System.DateTime.Now.Date.AddDays(-PDaysToCalculate);

	mSql_PayspotPayments := 
		Select distinct  TokenId
		from PayspotPayments
		where Result = "00"
		   and DateCompleted >= LimitDate;

	mSql_NeuroFeatureTokens := 
		select TokenId, MachineId, Value, Currency
		from NeuroFeatureTokens
		where Created >= LimitDate;
		
	mSql_StateMachineCurrentStates := 
		select StateMachineId
		from StateMachineCurrentStates
		where StateMachineId in (select MachineId from mSql_NeuroFeatureTokens)
			and State = "PaymentNotPerformed";
	
	TokenId := "";
	MachineId := "";
	
	trn_SuccessCnt := 0;
	trn_SuccessValue := 0;
	trn_Currency := "";
	trn_FailedCnt := 0;

	foreach row in mSql_NeuroFeatureTokens do (
		TokenId := row[0];
		MachineId := row[1];
		
		if (Contains(mSql_PayspotPayments, TokenId)) then (
			trn_SuccessCnt ++;
			trn_SuccessValue += row[2];
			trn_Currency := row[3];
		)else (
			if(Contains(mSql_StateMachineCurrentStates, MachineId)) then(
				trn_FailedCnt++;
			);
		);
	);
	
	ReponseDict.Add("trn_TotalValue:" + trn_Currency, String(trn_SuccessValue));
	ReponseDict.Add("trn_TotalSuccess" , String(trn_SuccessCnt));
	ReponseDict.Add("trn_TotalFailed", String(trn_FailedCnt));

)
catch(
	Log.Error(Exception, null);
	BadRequest(Exception.Message);
);

return (ReponseDict);
