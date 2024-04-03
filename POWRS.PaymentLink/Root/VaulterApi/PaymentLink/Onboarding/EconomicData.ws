SessionUser:= Global.ValidateAgentApiToken(false, false);

({
   "RetailersNumber":Required(Int(PRetailersNumber)),
   "ExpectedMonthlyTurnover":Required(Num(PExpectedMonthlyTurnover)),
   "ExpectedYearlyTurnover":Required(Num(PExpectedYearlyTurnover)),
   "ThreeMonthAccountTurnover":Required(Num(PThreeMonthAccountTurnover)),
   "CardPaymentPercentage":Required(Num(PCardPaymentPercentage)),
   "AverageTransactionAmount":Required(Num(PAverageTransactionAmount)),
   "AverageDailyTurnover":Required(Num(PAverageDailyTurnover)),
   "CheapestProductAmount":Required(Num(PCheapestProductAmount)),
   "MostExpensiveProductAmount":Required(Num(PMostExpensiveProductAmount))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
 companyEconomicData:= select top 1 * from POWRS.PaymentLink.Onboarding.EconomicData where UserName = SessionUser.username;
 if(companyEconomicData == null) then 
 (
	instance := POWRS.PaymentLink.Onboarding.EconomicData.CreateInstance(Posted);
	instance.UserName:= SessionUser.username;
	Waher.Persistence.Database.Insert(instance);
 )
 else
 (
	instance := POWRS.PaymentLink.Onboarding.EconomicData.CreateInstance(companyInformation, Posted);
	Waher.Persistence.Database.Update(instance);
 );
)
catch
(
	Log.Error(Exception, "EconomicData", SessionUser.username, null);
	BadRequest(Exception.Message);
)