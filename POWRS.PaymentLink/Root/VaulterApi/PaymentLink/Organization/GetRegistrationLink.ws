SessionUser := Global.ValidateAgentApiToken(false, false);

({
    "parentOrgName": Required(Str(PParentOrgName)),
    "newOrgName": Required(Str(PNewOrgName)),
    "newOrgClientType": Required(Str(PNewOrgClientType)),
    "newUserRole": Required(Str(PNewUserRole))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "GetRegistrationLink.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];
currentStep := "";

ValidatePostedData(PParentOrgName, PNewOrgName, PNewOrgClientType, PNewUserRole) := (
	permissionToAccessOrg := false;

	errors:= Create(System.Collections.Generic.List, System.String);
	if(System.String.IsNullOrWhiteSpace(PParentOrgName))then
	(
		errors.Add("parentOrgName");
	);
	if(!permissionToAccessOrg)then
	(
		errors.Add("parentOrgName;PermissionToAccessOrgName");
	);
	if(!POWRS.PaymentLink.Models.EnumHelper.IsEnumDefined(POWRS.PaymentLink.Models.AccountRole, PNewUserRole))then
	(
		errors.Add("newUserRole")
	)
	else
	(
		newUserRole := System.Enum.Parse(POWRS.PaymentLink.Models.AccountRole, PNewUserRole);
		if(newUserRole = POWRS.PaymentLink.Models.AccountRole.GroupAdmin)then
		(
			if(System.String.IsNullOrWhiteSpace(PNewOrgName))then
			(
				errors.Add("newOrgName")
			);
			
			if(!POWRS.PaymentLink.Models.EnumHelper.IsEnumDefined(POWRS.PaymentLink.ClientType.Enums.ClientType, PNewOrgClientType))then
			(
				errors.Add("newOrgClientType")
			);
		);
	);
	
	if(errors.Count > 0)then
	(
	   Error(errors);
	);
	
	Return(1);
);

try
(
	Log.Debug("Posted data: \n" + Str(Posted), logObject, logActor, logEventID, null);
	
	currentStep := "ValidatePostedData";
	ValidatePostedData(PParentOrgName, PNewOrgName, PNewOrgClientType, PNewUserRole);
	Log.Debug("Finished Validation method", logObject, logActor, logEventID, null);
	
	currentStep := "CollectingData";
	newUserRole := System.Enum.Parse(POWRS.PaymentLink.Models.AccountRole, PNewUserRole);
	newOrgClientType := null;
	
	if(newUserRole = POWRS.PaymentLink.Models.AccountRole.GroupAdmin)then
	(
		newOrgClientType := System.Enum.Parse(POWRS.PaymentLink.ClientType.Enums.ClientType, PNewOrgClientType);
	)
	else
	(
		newOrgClientType := 
			select top 1 OrgClientType 
			from POWRS.PaymentLink.ClientType.Models.OrganizationClientType 
			where OrganizationName = PParentOrgName;
	);
	
	currentStep := "DB Insert-Update";
	newId := "";
	
	newUserRegistrationDetails := 
		select top 1 * 
		from POWRS.PaymentLink.Models.NewUserRegistrationDetails 
		where ParentOrgName = PParentOrgName and
			NewOrgName = PNewOrgName and
			NewOrgClientType = PNewOrgName and
			NewUserRole = newUserRole;
			
	if(newUserRegistrationDetails != null)then
	(
		newId := newUserRegistrationDetails.ObjectId;
	)
	else
	(
		newUserRegistrationDetails := Create(POWRS.PaymentLink.Models.NewUserRegistrationDetails);
		newUserRegistrationDetails.ParentOrgName := PParentOrgName;
		newUserRegistrationDetails.NewOrgName := PNewOrgName;
		newUserRegistrationDetails.NewOrgClientType := newOrgClientType;
		newUserRegistrationDetails.NewUserRole := newUserRole;
		newUserRegistrationDetails.CreatorUserName := SessionUser.username;
		newUserRegistrationDetails.Created := Now;
		
		Waher.Persistence.Database.Insert(newUserRegistrationDetails);
		newId := select top 1 ObjectId from POWRS.PaymentLink.Models.NewUserRegistrationDetails order by ObjectId desc;
	);
	
	currentStep := "CreateUrl";
	siteUrl := Create(System.Text.StringBuilder);
	siteUrl.Append("https://paylink.vaulter.rs/index.html#/");
	siteUrl.Append(POWRS.PaymentLink.ClientType.Enums.EnumHelper.GetPathNameByEnum(newOrgClientType));
	siteUrl.Append("?id=" + newId);
	
	Log.Informational("Succeffully generated registration URL: " + Str(siteUrl), logObject, logActor, logEventID, null);
	
	{
		"registrationUrl": Str(siteUrl)
	}
)
catch
(
	Log.Error("Current step: " + currentStep + "\nEx.msg: " + Exception.Message, logObject, logActor, logEventID, null);
	if(errors.Count > 0) then 
	(
		BadRequest(errors);
	)
	else 
	(
		BadRequest(Exception.Message);
	);
)
finally
(
    Destroy(siteUrl);
);

