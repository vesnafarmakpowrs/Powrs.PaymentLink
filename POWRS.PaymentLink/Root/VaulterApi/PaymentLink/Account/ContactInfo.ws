Response.SetHeader("Access-Control-Allow-Origin","*");
ValidatedUser:= Global.ValidateAgentApiToken(false, false);

({
    "orgPhoneNumber": Required(Str(POrgPhoneNumber)),
    "orgWebAddress": Required(Str(POrgWebAddress)),
    "orgEmailAddress": Required(Str(POrgEmailAddress)),
    "orgTermsAndConditionsUrl": Required(Str(POrgTermsAndConditions))  
}:=Posted) ??? BadRequest(Exception.Message);

ValidateUrl(url):= 
(
    urlResponse:= HEAD(url);
    if(urlResponse == null) then 
    (
        Error("Invalid urlResponse for url: " + url);
    );

    if(urlResponse.StatusCode == 400) then
    (
        Error("Website url not found: " + webSiteResponse.Message + " " + url);
    );
);
try
(
   if(POrgPhoneNumber not like "^[+]?[0-9]{6,15}$") then 
(
	Error("Phone not in correct format");
);
   if(POrgWebAddress not like ^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$") then 
(
	Error("WebAddress not in correct format");
);
   if(POrgEmailAddress not like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}") then 
(
	Error("Email not in correct format");
);
   if(POrgTermsAndConditions not like ^(https?:\\/\\/)(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+(\\/[^\\s]*)?$") then 
(
	Error("Terms and conditions url not in correct format");
);
    ValidateUrl(POrgWebAddress);
    ValidateUrl(POrgTermsAndConditions);

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
    BadRequest(Exception.Message);
);
