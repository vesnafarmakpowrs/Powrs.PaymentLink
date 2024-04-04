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
 dict:= Create(System.Collections.Generic.Dictionary, System.String, System.Object);
 foreach(item in Posted) do ( dict.Add(item.Key, item.Value););
 newRecord:= false;

 data:= select top 1 * from POWRS.PaymentLink.Onboarding.EconomicData where UserName = SessionUser.username;
 if(data == null) then 
 (
    newRecord:= true;
	data := Create(POWRS.PaymentLink.Onboarding.EconomicData, SessionUser.username);
 );

 data.Fill(data, dict);

 if(newRecord) then 
 (
	Waher.Persistence.Database.Insert(data);
 )
 else
 (
	Waher.Persistence.Database.Update(data);
 );
)
catch
(
	Log.Error(Exception, "EconomicData", SessionUser.username, null);
	BadRequest(Exception.Message);
)