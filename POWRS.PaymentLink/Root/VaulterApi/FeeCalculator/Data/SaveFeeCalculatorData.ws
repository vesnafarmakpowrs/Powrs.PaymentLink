SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "SaveFeeCalculatorData.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

if(Posted == null) then NotAcceptable("Data could not be null");

errors:= Create(System.Collections.Generic.List, System.String);
currentMethod:= "";

ValidatePostedData(Posted) := (
	if(!exists(Posted.CurrentData) or Posted.CurrentData == null) then errors.Add("CurrentData could not be null");
	if(!exists(Posted.CardData) or Posted.CardData == null) then errors.Add("CardData could not be null");
	if(!exists(Posted.A2AData) or Posted.A2AData == null) then errors.Add("A2AData could not be null");
	if(!exists(Posted.HoldingServiceData) or Posted.HoldingServiceData == null) then errors.Add("HoldingServiceData could not be null");
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);

	if(!exists(Posted.CompanyName) or
		System.String.IsNullOrWhiteSpace(Posted.CompanyName))then
	(
		errors.Add("CompanyName");
	);
	if(!exists(Posted.OrganizationNumber) or
		System.String.IsNullOrWhiteSpace(Posted.OrganizationNumber))then
	(
		errors.Add("OrganizationNumber");
	);
	if(!exists(Posted.ContactPerson) or
		System.String.IsNullOrWhiteSpace(Posted.ContactPerson))then
	(
		errors.Add("ContactPerson");
	);
	if(!exists(Posted.ContactEmail) or
		System.String.IsNullOrWhiteSpace(Posted.ContactEmail))then
	(
		errors.Add("ContactEmail");
	);
	Double(Posted.TotalSaved) ??? errors.Add("TotalSaved");
	Double(Posted.KickBack_Discount) ??? errors.Add("KickBack_Discount");
	if(!exists(Posted.Currency) or
		System.String.IsNullOrWhiteSpace(Posted.Currency))then
	(
		errors.Add("Currency");
	);
	
	Int(Posted.CurrentData.TotalRevenue) ??? errors.Add("CurrentData.TotalRevenue");
	Double(Posted.CurrentData.AverageAmount) ??? errors.Add("CurrentData.AverageAmount");
	Int(Posted.CurrentData.TotalTransactions) ??? errors.Add("CurrentData.TotalTransactions");
	Double(Posted.CurrentData.CardTransactionPercentage) ??? errors.Add("CurrentData.CardTransactionPercentage");
	Double(Posted.CurrentData.CardFee) ??? errors.Add("CurrentData.CardFee");
	Int(Posted.CurrentData.TotalCardTransactions) ??? errors.Add("CurrentData.TotalCardTransactions");
	Double(Posted.CurrentData.TotalCardCost) ??? errors.Add("CurrentData.TotalCardCost");
	
	if(!exists(Posted.CardData.ShowGroup))then
	(
		errors.Add("CardData.ShowGroup");
	);
	Double(Posted.CardData.TransactionPercentage) ??? errors.Add("CardData.TransactionPercentage");
	Int(Posted.CardData.NumberOfTransactions) ??? errors.Add("CardData.NumberOfTransactions");
	Double(Posted.CardData.AverageAmount) ??? errors.Add("CardData.AverageAmount");
	Double(Posted.CardData.Fee) ??? errors.Add("CardData.Fee");
	Double(Posted.CardData.Cost) ??? errors.Add("CardData.Cost");
	Double(Posted.CardData.Saved) ??? errors.Add("CardData.Saved");
	
	if(!exists(Posted.A2AData.ShowGroup))then
	(
		errors.Add("A2AData.ShowGroup");
	);
	Double(Posted.A2AData.TransactionPercentage) ??? errors.Add("A2AData.TransactionPercentage");
	Int(Posted.A2AData.NumberOfTransactions) ??? errors.Add("A2AData.NumberOfTransactions");
	Double(Posted.A2AData.AverageAmount) ??? errors.Add("A2AData.AverageAmount");
	Double(Posted.A2AData.Fee) ??? errors.Add("A2AData.Fee");
	Double(Posted.A2AData.Cost) ??? errors.Add("A2AData.Cost");
	Double(Posted.A2AData.Saved) ??? errors.Add("A2AData.Saved");
	
	if(!exists(Posted.HoldingServiceData.ShowGroup))then
	(
		errors.Add("HoldingServiceData.ShowGroup");
	);
	Double(Posted.HoldingServiceData.TransactionPercentage) ??? errors.Add("HoldingServiceData.TransactionPercentage");
	Int(Posted.HoldingServiceData.NumberOfTransactions) ??? errors.Add("HoldingServiceData.NumberOfTransactions");
	Double(Posted.HoldingServiceData.Fee) ??? errors.Add("HoldingServiceData.Fee");
	Double(Posted.HoldingServiceData.Cost) ??? errors.Add("HoldingServiceData.Cost");
	if(!exists(Posted.HoldingServiceData.CostPay))then
	(
		errors.Add("HoldingServiceData.CostPay");
	);
	Double(Posted.HoldingServiceData.KickBackPerTransaction) ??? errors.Add("HoldingServiceData.KickBackPerTransaction");
	Double(Posted.HoldingServiceData.IncomeSummary) ??? errors.Add("HoldingServiceData.IncomeSummary");
	
	if(errors.Count > 0)then
	(
		Error(errors);
	);
	
	return (1); 
);

SaveData(Posted, userName) := (
	feeCalculatorObj := select top 1 * from POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator where OrganizationNumber = Posted.OrganizationNumber;
	recordExists := feeCalculatorObj != null;
	
	if(recordExists)then
	(
		feeCalculatorObj.EditorUserName := userName;
		feeCalculatorObj.Edited := Now;
	)
	else
	(
		feeCalculatorObj := Create(POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator);
		feeCalculatorObj.CurrentData := Create(POWRS.PaymentLink.FeeCalculator.Data.Current);
		feeCalculatorObj.CardData := Create(POWRS.PaymentLink.FeeCalculator.Data.Card);
		feeCalculatorObj.A2AData := Create(POWRS.PaymentLink.FeeCalculator.Data.A2A);
		feeCalculatorObj.HoldingServiceData := Create(POWRS.PaymentLink.FeeCalculator.Data.HoldingService);
		
		feeCalculatorObj.CreatorUserName := userName;
		feeCalculatorObj.Created := Now;
		feeCalculatorObj.OrganizationNumber := Posted.OrganizationNumber;
	);
	
	feeCalculatorObj.CompanyName := Posted.CompanyName;
	feeCalculatorObj.ContactPerson := Posted.ContactPerson;
	feeCalculatorObj.ContactEmail := Posted.ContactEmail;	
	
	feeCalculatorObj.CurrentData.TotalRevenue := Posted.CurrentData.TotalRevenue;
	feeCalculatorObj.CurrentData.AverageAmount := Posted.CurrentData.AverageAmount;
	feeCalculatorObj.CurrentData.TotalTransactions := Posted.CurrentData.TotalTransactions;
	feeCalculatorObj.CurrentData.CardTransactionPercentage := Posted.CurrentData.CardTransactionPercentage;
	feeCalculatorObj.CurrentData.CardFee := Posted.CurrentData.CardFee;
	feeCalculatorObj.CurrentData.TotalCardTransactions := Posted.CurrentData.TotalCardTransactions;
	feeCalculatorObj.CurrentData.TotalCardCost := Posted.CurrentData.TotalCardCost;
	
	feeCalculatorObj.CardData.ShowGroup := Posted.CardData.ShowGroup;
	feeCalculatorObj.CardData.TransactionPercentage := Posted.CardData.TransactionPercentage;
	feeCalculatorObj.CardData.NumberOfTransactions := Posted.CardData.NumberOfTransactions;
	feeCalculatorObj.CardData.AverageAmount := Posted.CardData.AverageAmount;
	feeCalculatorObj.CardData.Fee := Posted.CardData.Fee;
	feeCalculatorObj.CardData.Cost := Posted.CardData.Cost;
	feeCalculatorObj.CardData.Saved := Posted.CardData.Saved;
	
	feeCalculatorObj.A2AData.ShowGroup := Posted.A2AData.ShowGroup;
	feeCalculatorObj.A2AData.TransactionPercentage := Posted.A2AData.TransactionPercentage;
	feeCalculatorObj.A2AData.NumberOfTransactions := Posted.A2AData.NumberOfTransactions;
	feeCalculatorObj.A2AData.AverageAmount := Posted.A2AData.AverageAmount;
	feeCalculatorObj.A2AData.Fee := Posted.A2AData.Fee;
	feeCalculatorObj.A2AData.Cost := Posted.A2AData.Cost;
	feeCalculatorObj.A2AData.Saved := Posted.A2AData.Saved;
	
	feeCalculatorObj.HoldingServiceData.ShowGroup := Posted.HoldingServiceData.ShowGroup;
	feeCalculatorObj.HoldingServiceData.TransactionPercentage := Posted.HoldingServiceData.TransactionPercentage;
	feeCalculatorObj.HoldingServiceData.NumberOfTransactions := Posted.HoldingServiceData.NumberOfTransactions;
	feeCalculatorObj.HoldingServiceData.Fee := Posted.HoldingServiceData.Fee;
	feeCalculatorObj.HoldingServiceData.Cost := Posted.HoldingServiceData.Cost;
	feeCalculatorObj.HoldingServiceData.CostPay := System.Enum.Parse(POWRS.PaymentLink.FeeCalculator.Enums.CostPay, Posted.HoldingServiceData.CostPay) ??? POWRS.PaymentLink.FeeCalculator.Enums.CostPay.Buyer;
	feeCalculatorObj.HoldingServiceData.KickBackPerTransaction := Posted.HoldingServiceData.KickBackPerTransaction;
	feeCalculatorObj.HoldingServiceData.IncomeSummary := Posted.HoldingServiceData.IncomeSummary;
	
	feeCalculatorObj.TotalSaved := Posted.TotalSaved;
	feeCalculatorObj.KickBack_Discount := Posted.KickBack_Discount;
	feeCalculatorObj.Currency := Posted.Currency;
	
	if(recordExists)then
	(
		Waher.Persistence.Database.Update(feeCalculatorObj);
	)
	else
	(
		Waher.Persistence.Database.Insert(feeCalculatorObj);
	);
);

try
(
	Log.Informational("Calling save fee calculator data. Posted:" + Str(Posted), logObject, logActor, logEventID, null);

	currentMethod := "ValidatePostedData"; 
	ValidatePostedData(Posted);
	
	currentMethod := "SaveData"; 
	SaveData(Posted, SessionUser.username);
	
	Log.Informational("Succeffully saved fee calculator data.", logObject, logActor, logEventID, null);
	{
		success: true
	}
)
catch
(
	Log.Error("Unable to save fee calculator data: " + Exception.Message + "\ncurrentMethod: " + currentMethod, logObject, logActor, logEventID, null);
    if(errors.Count > 0) then 
    (
		NotAcceptable(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);




