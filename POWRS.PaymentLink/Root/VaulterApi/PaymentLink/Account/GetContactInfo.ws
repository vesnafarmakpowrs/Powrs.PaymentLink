Response.SetHeader("Access-Control-Allow-Origin","*");

ValidatedUser:= Global.ValidateAgentApiToken(false, false);

try
(
     contactInfo:= select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = ValidatedUser.orgName;
     if(contactInfo != null) then 
     (
	    {
 		    "Account": contactInfo.Account,
 		    "WebAddress": contactInfo.WebAddress,
 		    "Email": contactInfo.Email,
 		    "PhoneNumber": contactInfo.PhoneNumber,
 		    "TermsAndConditions": contactInfo.TermsAndConditions
        }
    );
)	
catch
(
    Log.Error(Exception, "", "GetContactInfo", "", null);
	BadRequest(Exception.Message);
);
