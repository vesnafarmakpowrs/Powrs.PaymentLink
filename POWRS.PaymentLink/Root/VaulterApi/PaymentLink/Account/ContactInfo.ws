ValidatedUser:= Global.ValidateAgentApiToken(false, false);

if(ValidatedUser.role != POWRS.PaymentLink.Models.AccountRole.ClientAdmin.ToString()) then 
(
    Forbidden("");
);

({
    "PhoneNumber": Required(Str(POrgPhoneNumber)),
    "WebAddress": Required(Str(POrgWebAddress)),
    "Email": Required(Str(POrgEmailAddress)),
    "TermsAndConditions": Required(Str(POrgTermsAndConditions))
}:=Posted) ??? BadRequest(Exception.Message); 

logObject := ValidatedUser.username;
logEventID := "ContactInfo.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

IsValidBase64(base64String):= 
(
    isSuccess:= true;
    try
    (
        if(System.String.IsNullOrWhiteSpace(base64String)) then 
        (
            Error("");
        );

        byteArray:= System.Convert.FromBase64String(base64String);
        maxSize:= 1.5 * 1024 * 1024;
        if(byteArray.Length > maxSize) then 
        (
            Error("");
        );
    )
    catch
    (
        isSuccess:= false;
    );

    isSuccess;
);

errors:= Create(System.Collections.Generic.List, System.String);

try
(
	if(Global.RegexValidation(POrgPhoneNumber, "PhoneNumber", "") == false) then
	(
		errors.Add("PhoneNumber");
	);
	if(ValidateUrl(POrgWebAddress) == false) then 
	(
		errors.Add("WebAddress");
	);
	if(Global.RegexValidation(POrgEmailAddress, "Email", "") == false) then 
	(
		errors.Add("Email");
	);

	if(System.String.IsNullOrEmpty(POrgTermsAndConditions) or 
		(!ValidateUrl(POrgTermsAndConditions) and !IsValidBase64(POrgTermsAndConditions))
	) then 
	(
		errors.Add("TermsAndConditions");
	);

	if(errors.Count > 0) then 
	(
		BadRequest(errors);
	);

	if(ValidatedUser.orgName == "")then
	(
		BadRequest("You need to apply for legal id first");
	);

	organizationInfo:= select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = ValidatedUser.orgName;

	if(organizationInfo != null) then 
	(
		organizationInfo.WebAddress:= POrgWebAddress;
		organizationInfo.Email:= POrgEmailAddress;
		organizationInfo.PhoneNumber:= POrgPhoneNumber;
		organizationInfo.TermsAndConditions:= POrgTermsAndConditions;

		Waher.Persistence.Database.Update(organizationInfo);
	)
	else
	(
		info:= Create(POWRS.PaymentLink.Models.OrganizationContactInformation);
		info.OrganizationName:= ValidatedUser.orgName;
		info.WebAddress:= POrgWebAddress;
		info.Email:= POrgEmailAddress;
		info.PhoneNumber:= POrgPhoneNumber;
		info.TermsAndConditions:= POrgTermsAndConditions;

		Waher.Persistence.Database.Insert(info);
	);

	{
	}
)
catch
(
	Log.Error("Unable to save contact info: " + Exception.Message, logObject, logActor, logEventID, null);

    if(errors.Count > 0) then 
    (
        BadRequest(errors);
    )
    else 
    (
        BadRequest(Exception.Message);
    );
);
