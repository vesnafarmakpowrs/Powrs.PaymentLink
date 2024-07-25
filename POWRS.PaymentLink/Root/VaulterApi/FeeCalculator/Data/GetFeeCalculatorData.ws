SessionUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "GetFeeCalculatorData.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

({
    "ObjectId": Optional(Str(PObjectId))
}:=Posted) ??? BadRequest("Request does not conform to the specification");

try
(
	if(PObjectId != null and PObjectId != "")then 
	(
		feeCalcObj := select top 1 * from POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator where ObjectId = PObjectId;
		Generalize(feeCalcObj);
	)
	else
	(
		select * from POWRS.PaymentLink.FeeCalculator.Data.FeeCalculator where CreatorUserName = SessionUser.username or EditorUserName = SessionUser.username;		
	);
)
catch
(
	Log.Error("Unable to get fee calculator data: " + Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);




