ValidatedUser:= Global.ValidateAgentApiToken(false, false);

logObject := SessionUser.username;
logEventID := "GetLegalIdentityInfo.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	if(System.String.IsNullOrEmpty(ValidatedUser.legalId)) then 
	(
		Identity := select top 1 Properties from LegalIdentities where Account = ValidatedUser.username and State = "Created" order by Created desc;
	)
	else
	(
		Identity := select top 1 Properties from LegalIdentities where Id = ValidatedUser.legalId;
	);

	IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
	hasApplied := false;
	isSubAccount := false;
	
	if(Identity != null) then 
	(
		foreach Parameter in Identity do 
		(
			Parameter.Value != null ? IdentityProperties.Add(Parameter.Name, Parameter.Value);
		);
		hasApplied := IdentityProperties.Count > 0;
	)
	else 
	(			
		brokerAccRole := 
			Select top 1 *
			from POWRS.PaymentLink.Models.BrokerAccountRole
			where UserName = ValidatedUser.username;
		
		if(brokerAccRole != null && brokerAccRole.Role == POWRS.PaymentLink.Models.AccountRole.ClientAdmin) then
		(
			creatorIdentity := 
				select top 1 Properties 
				from LegalIdentities 
				where Account = brokerAccRole.CreatorUserName 
					and State = "Approved" 
				order by Created desc;
			
			if(creatorIdentity != null) then 
			(
				foreach Parameter in creatorIdentity do 
				(
					if(Parameter.Value != null && Parameter.Name != "FIRST" && Parameter.Name != "LAST" && Parameter.Name != "PNR" && Parameter.Name != "COUNTRY") then
					( 
						IdentityProperties.Add(Parameter.Name, Parameter.Value);
					);
				);
				isSubAccount := true;
			);
		);
	);
	
	{
		"Properties": IdentityProperties,
		"HasApplied": hasApplied,
		"IsSubAccount": isSubAccount
	}
)
catch
(
	Log.Error("Unable retrive legal id info: " + Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);