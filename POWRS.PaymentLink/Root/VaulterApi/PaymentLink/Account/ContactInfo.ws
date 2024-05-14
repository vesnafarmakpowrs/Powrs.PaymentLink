Response.SetHeader("Access-Control-Allow-Origin","*");
ValidatedUser:= Global.ValidateAgentApiToken(false, false);

({
    "PhoneNumber": Required(Str(POrgPhoneNumber)),
    "WebAddress": Required(Str(POrgWebAddress)),
    "Email": Required(Str(POrgEmailAddress)),
    "TermsAndConditions": Required(Str(POrgTermsAndConditions))
}:=Posted) ??? BadRequest(Exception.Message);

ValidateUrl(url):= 
(
    isSuccess:= true;
    try 
    (
        if(url not like "^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$") then 
        (
           Error("");
        );

        urlResponse:= HEAD(url);
        isSuccess:= urlResponse.StatusCode != 404;
    )
    catch 
    (
       isSuccess:= false;
    );

    isSuccess;
);

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
   if(POrgPhoneNumber not like "^[+]?[0-9]{6,15}$") then 
(
	errors.Add("PhoneNumber");
);
   if(POrgWebAddress not like "^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$" or ValidateUrl(POrgWebAddress) == false) then 
(
	errors.Add("WebAddress");
);
   if(POrgEmailAddress not like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}") then 
(
	errors.Add("Email");
);

if(System.String.IsNullOrEmpty(POrgTermsAndConditions) or 
    (!ValidateUrl(POrgTermsAndConditions) and !IsValidBase64(POrgTermsAndConditions))) then 
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
    Log.Error(Exception, "", "ContactInfo", "", null);

    if(errors.Count > 0) then 
    (
          BadRequest(errors);
    )
    else 
    (
          BadRequest(Exception.Message);
    );
);
