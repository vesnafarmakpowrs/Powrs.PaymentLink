Response.SetHeader("Access-Control-Allow-Origin","*");

ValidatedUser:= Global.ValidateAgentApiToken(false, false);

try
(
    if(ValidatedUser.orgName != "") then
    (
         contactInfo:= select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = ValidatedUser.orgName;
         if(contactInfo != null and ) then 
         (
	        {
 		        "Account": ValidatedUser.username,
 		        "WebAddress": contactInfo.WebAddress,
 		        "Email": contactInfo.Email,
 		        "PhoneNumber": contactInfo.PhoneNumber,
 		        "TermsAndConditions": contactInfo.TermsAndConditions
            }
        );
    );
)	
catch
(
    Log.Error(Exception, "", "GetContactInfo", "", null);
	BadRequest(Exception.Message);
);
