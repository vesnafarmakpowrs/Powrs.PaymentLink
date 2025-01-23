SessionUser := Global.ValidateSmartAdminApiToken();

comment := "!!! Handled use cases in file: project/DataModel/GetRegistrationLink_Usecases.pdf";

({
    "parentOrgName": Required(Str(PParentOrgName)),
    "newOrgName": Required(Str(PNewOrgName)),
    "newOrgClientType": Required(Str(PNewOrgClientType)),
    "newUserRole": Required(Str(PNewUserRole))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "RegistrationLinkCreate.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];
currentStep := "";
errors:= Create(System.Collections.Generic.List, System.String);

ValidatePostedData(parentOrgName, newOrgName, newOrgClientType, newUserRole) := (
	if(System.String.IsNullOrWhiteSpace(parentOrgName) or Global.RegexValidation(parentOrgName, "OrgName", "") == false)then
	(
		errors.Add("parentOrgName");
	)
	else
	(
		myOrganizations := POWRS.PaymentLink.Models.BrokerAccountRole.GetAllOrganizationChildren(SessionUser.orgName);
		
		if(!myOrganizations.Contains(parentOrgName))then
		(
			errors.Add("parentOrgName;do not have permission to access OrgName");
		);
	);
	if(SessionUser.role == POWRS.PaymentLink.Models.AccountRole.SuperAdmin.ToString())then
	(
		if(!System.Enum.IsDefined(POWRS.PaymentLink.Models.AccountRole, newUserRole))then
		(
			errors.Add("newUserRole");
		)
		else
		(				
			newUserRole := System.Enum.Parse(POWRS.PaymentLink.Models.AccountRole, newUserRole);
			if (newUserRole != POWRS.PaymentLink.Models.AccountRole.GroupAdmin and newUserRole != POWRS.PaymentLink.Models.AccountRole.ClientAdmin)then
			(
				errors.Add("newUserRole;invalid user role");
			);
	
			if(newUserRole == POWRS.PaymentLink.Models.AccountRole.GroupAdmin)then
			(
				comment := "When creating GroupAdmin: ParentOrgName MUST BE 'Powrs', newOrgName mandatory, newOrgClientType: mandatory, newUserRole: mandatory ";
				if(parentOrgName != "Powrs")then
				(
					errors.Add("parentOrgName");
				);
				if(System.String.IsNullOrWhiteSpace(newOrgName) or Global.RegexValidation(newOrgName, "OrgName", "") == false)then
				(
					errors.Add("newOrgName");
				);
				if(!System.Enum.IsDefined(POWRS.PaymentLink.ClientType.Enums.ClientType, newOrgClientType))then
				(
					errors.Add("newOrgClientType");
				);					
			)
			else
			(
				comment := "When creating ClientAdmin: parentOrgName can be 'powrs' or other";
				if(parentOrgName == "Powrs")then
				(
					comment := "if is POWRS then newOrgName = '', newOrgClientType: mandatory";
					if(!System.Enum.IsDefined(POWRS.PaymentLink.ClientType.Enums.ClientType, newOrgClientType))then
					(
						errors.Add("newOrgClientType");
					);
				)
				else
				(
					comment := "if not POWRS then newOrgName = '', newOrgClientType: empty";
				);					
			);
		);
	)
	else
	(
		comment := "SessionUser role: Group admin -> ParentOrgName = from SessionUser.orgname, newOrgName = '' (will be entered on registration), newOrgClientType = from SessionUser, newUserRole: ClientAdmin ";
		if(parentOrgName != SessionUser.orgName)then
		(
			errors.Add("parentOrgName");
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
	newOrgClientType := null;
	
	newUserRegistrationDetail := Create(POWRS.PaymentLink.Models.NewUserRegistrationDetail);
	newUserRegistrationDetail.Created := Now;
	newUserRegistrationDetail.Creator := SessionUser.username;
	newUserRegistrationDetail.SuccessfullyRegisteredUserName := "";
	
	comment := "Handle when logged in SuperAdmin";
	if(SessionUser.role == POWRS.PaymentLink.Models.AccountRole.SuperAdmin.ToString())then
	(
		newUserRole := System.Enum.Parse(POWRS.PaymentLink.Models.AccountRole, PNewUserRole);
		if(newUserRole == POWRS.PaymentLink.Models.AccountRole.GroupAdmin)then
		(
			comment := "When creating GroupAdmin: ParentOrgName MUST BE 'Powrs', newOrgName mandatory, newOrgClientType: mandatory, newUserRole: mandatory ";
			newOrgClientType := System.Enum.Parse(POWRS.PaymentLink.ClientType.Enums.ClientType, PNewOrgClientType);
			
			newUserRegistrationDetail.ParentOrgName := PParentOrgName;
			newUserRegistrationDetail.NewOrgName := PNewOrgName;
			newUserRegistrationDetail.NewOrgClientType := newOrgClientType;
			newUserRegistrationDetail.NewUserRole := newUserRole;
		)
		else
		(
			comment := "When creating ClientAdmin: parentOrgName can be 'powrs' or other";			
			if(PParentOrgName == "Powrs")then
			(
				comment := "if is POWRS then newOrgName = '', newOrgClientType: mandatory";
				newOrgClientType := System.Enum.Parse(POWRS.PaymentLink.ClientType.Enums.ClientType, PNewOrgClientType);
				
				newUserRegistrationDetail.ParentOrgName := PParentOrgName;
				newUserRegistrationDetail.NewOrgName := "";
				newUserRegistrationDetail.NewOrgClientType := newOrgClientType;
				newUserRegistrationDetail.NewUserRole := newUserRole;
			)
			else
			(
				comment := "if not POWRS then newOrgName = '', newOrgClientType: ''";
				
				newUserRegistrationDetail.ParentOrgName := PParentOrgName;
				newUserRegistrationDetail.NewOrgName := "";
				newUserRegistrationDetail.NewOrgClientType := select top 1 OrgClientType from POWRS.PaymentLink.ClientType.Models.OrganizationClientType where OrganizationName = PParentOrgName;
				newUserRegistrationDetail.NewUserRole := newUserRole;
			);		
		);
	)
	else
	(
		comment := "SessionUser role: Group admin -> ParentOrgName = from SessionUser.orgname, newOrgName = '' (will be entered on registration), newOrgClientType = from SessionUser, newUserRole: ClientAdmin ";
		
		newUserRegistrationDetail.ParentOrgName := PParentOrgName;
		newUserRegistrationDetail.NewOrgName := "";
		newUserRegistrationDetail.NewOrgClientType := select top 1 OrgClientType from POWRS.PaymentLink.ClientType.Models.OrganizationClientType where OrganizationName = PParentOrgName;
		newUserRegistrationDetail.NewUserRole := POWRS.PaymentLink.Models.AccountRole.ClientAdmin;
	);
	
	currentStep := "DB Insert-Update";
	Waher.Persistence.Database.Insert(newUserRegistrationDetail);
	newId := select top 1 ObjectId from POWRS.PaymentLink.Models.NewUserRegistrationDetail order by ObjectId desc;
	
	currentStep := "CreateUrl";
	siteUrl := Create(System.Text.StringBuilder);
	siteUrl.Append("https://paylink.vaulter.rs/index.html#/registration");
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
