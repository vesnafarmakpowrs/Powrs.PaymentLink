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
errors:= Create(System.Collections.Generic.List, System.String);

ValidatePostedData(parentOrgName, newOrgName, newOrgClientType, newUserRole) := (
	if(System.String.IsNullOrWhiteSpace(parentOrgName) or Global.RegexValidation(parentOrgName, "OrgName", "") == false)then
	(
		errors.Add("parentOrgName");
	)else
	(
		myOrganizations := POWRS.PaymentLink.Models.BrokerAccountRole.GetAllOrganizationChildren(SessionUser.orgName);
		permissionToAccessOrg := myOrganizations.Contains(parentOrgName);
		
		if(!permissionToAccessOrg)then
		(
			errors.Add("parentOrgName;PermissionToAccessOrgName");
		);
	);
	if(!System.Enum.IsDefined(POWRS.PaymentLink.Models.AccountRole, newUserRole))then
	(
		errors.Add("newUserRole")
	)
	else
	(
		newUserRole := System.Enum.Parse(POWRS.PaymentLink.Models.AccountRole, newUserRole);
		if(newUserRole = POWRS.PaymentLink.Models.AccountRole.GroupAdmin)then
		(
			if(System.String.IsNullOrWhiteSpace(newOrgName) or Global.RegexValidation(newOrgName, "OrgName", "") == false)then
			(
				errors.Add("newOrgName")
			);
			
			if(!System.Enum.IsDefined(POWRS.PaymentLink.ClientType.Enums.ClientType, newOrgClientType))then
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
	currentStep := "ValidatePostedData";
	ValidatePostedData(PParentOrgName, PNewOrgName, PNewOrgClientType, PNewUserRole);
	
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
			NewOrgClientType = newOrgClientType and
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
