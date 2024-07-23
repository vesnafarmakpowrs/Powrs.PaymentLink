SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "SaveFeeCalculatorData.ws";
logActor := Request.RemoteEndPoint.Split(":", null)[0];

if(Posted == null) then NotAcceptable("Data could not be null");

errors:= Create(System.Collections.Generic.List, System.String);
currentMethod:= "";


ValidatePostedData(Posted) := (
	if(!exists(Posted.CurrentData) or Posted.CurrentData == null) then errors.Add("CurrentData could not be null");
	if(!exists(Posted.CardData) or Posted.CardData == null) then errors.Add("CardData could not be null");
	if(!exists(Posted.A2AData) or Posted.BusinessData == null) then errors.Add("A2AData could not be null");
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
	
);

try
(
	currentMethod := "ValidatePostedData"; 
	ValidatePostedData(Posted, SessionUser.username);
	
	
	currentMethod := "SaveData"; 
	SaveData(Posted);
	
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




