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
    isSuccess:= false;
    try 
    (
        urlResponse:= HEAD(url);
        isSuccess:= urlResponse.StatusCode != 404;
    )
    catch 
    (
       isSuccess:= false;
    );

    Return(isSuccess);
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
   if(POrgTermsAndConditions not like "^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$" or ValidateUrl(POrgTermsAndConditions) == false) then 
(
	errors.Add("TermsAndConditions");
);

if(errors.Count > 0) then 
(
    BadRequest(errors);
);

organizationInfo:= select top 1 * from POWRS.PaymentLink.OrganizationContactInfo where Account = ValidatedUser.username;

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
    info:= Create(POWRS.PaymentLink.OrganizationContactInfo);
    info.Account:= ValidatedUser.username;
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
    Log.Error(Exception, null);

    if(errors.Count > 0) then 
    (
          BadRequest(errors);
    )
    else 
    (
          BadRequest(Exception.Message);
    );
);
