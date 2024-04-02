SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"TrackDate":Required(Boolean(PTrackDate)),
	"DateFrom":Optional(String(PDateFrom)),
	"DateTo":Optional(String(PDateTo)),
	"Satus":Required(Integer(PStatus))
}:=Posted) ??? BadRequest(Exception.Message);

try(	
	Status_Success := 1;
	Status_Failed := 2;
		
	PDateFrom := PDateFrom ?? "";
	PDateTo := PDateTo ?? "";
	mSelect:="";
	
	responseList:= Create(System.Collections.Generic.List, System.Object);
	cancelAllowedStates:= {"AwaitingForPayment": true, "PaymentCompleted": true};
	doneStates:= {"Cancel": true, "Done": true, "": true, "PaymentNotPerformed": true};
	
	if(PTrackDate) then (
		if(IsEmpty(PDateFrom)) then 
		(
			Error("Date from must be entered");
		);
		if(IsEmpty(PDateTo)) then 
		(
			Error("Date to must be entered");
		);
		
		dateFormat := "dd/MM/yyyy";
		DTDateFrom := System.DateTime.ParseExact(PDateFrom, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := System.DateTime.ParseExact(PDateTo, dateFormat, System.Globalization.CultureInfo.CurrentUICulture);
		DTDateTo := DTDateTo.AddDays(1);
		
		if(PStatus == Status_Success) then (
			mSelect:=
				Select distinct TokenId
				from PayspotPayment pp
				where pp.DateCompleted >= DTDateFrom
					and pp.DateCompleted < DTDateTo;				
			
			foreach token in mSelect do (
				tokenObjs := 
					select * 
					from IoTBroker.NeuroFeatures.Token 
					where TokenId = token;
					
				foreach	tokenObj in tokenObjs do ( 
					variables := tokenObj.GetCurrentStateVariables();
					responseList.Add({
						"TokenId": tokenObj.TokenId,
						"CanCancel": exists(cancelAllowedStates[s.State]),
						"IsActive": !exists(doneStates[s.State]),
						"Created": tokenObj.Created.ToString("s"),
						"State": variables.State,
						"Variables": variables.VariableValues
					});		
				);
			);				
		) else (
			tokenObjs :=
				select * 
				from IoTBroker.NeuroFeatures.Token  t
				where t.Created >= DTDateFrom
					and t.Create < DTDateTo;
			
			foreach	tokenObj in tokenObjs do (
				variables := tokenObj.GetCurrentStateVariables();
				if (variables.State == "PaymentNotPerformed") then (
					responseList.Add({
						"TokenId": tokenObj.TokenId,
						"CanCancel": exists(cancelAllowedStates[s.State]),
						"IsActive": !exists(doneStates[s.State]),
						"Created": tokenObj.Created.ToString("s"),
						"State": variables.State,
						"Variables": variables.VariableValues
					});		
				);
			);
		);		
	) else (
		if(PStatus == Status_Success) then (
			mSelect:=
				Select distinct TokenId
				from PayspotPayment pp;
				
			foreach token in mSelect do (
				tokenObjs := 
					select * 
					from IoTBroker.NeuroFeatures.Token 
					where TokenId = token;
					
				foreach	tokenObj in tokenObjs do (
					variables := tokenObj.GetCurrentStateVariables();
					responseList.Add({
						"TokenId": tokenObj.TokenId,
						"CanCancel": exists(cancelAllowedStates[s.State]),
						"IsActive": !exists(doneStates[s.State]),
						"Created": tokenObj.Created.ToString("s"),
						"State": variables.State,
						"Variables": variables.VariableValues
					});
				);				
			);	
		) else (
			tokenObjs :=
				select * 
				from IoTBroker.NeuroFeatures.Token t;
			
			foreach	tokenObj in tokenObjs do (
				variables := tokenObj.GetCurrentStateVariables();
				if (variables.State == "PaymentNotPerformed") then (
					responseList.Add({
						"TokenId": tokenObj.TokenId,
						"CanCancel": exists(cancelAllowedStates[s.State]),
						"IsActive": !exists(doneStates[s.State]),
						"Created": tokenObj.Created.ToString("s"),
						"State": variables.State,
						"Variables": variables.VariableValues
					});		
				);
			);
		);
	);

)
catch(
	Log.Error(Exception, null);
	InternalServerError(Exception.Message);
);

return(responseList);