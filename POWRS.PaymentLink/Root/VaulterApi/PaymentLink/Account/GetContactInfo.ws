Response.SetHeader("Access-Control-Allow-Origin","*");

ValidatedUser:= Global.ValidateAgentApiToken(false, false);

try
(
     contactInfo:= select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = ValidatedUser.orgName;
     if(contactInfo != null) then 
     (
	    {
 		    "Account": ValidatedUser.username,
 		    "WebAddress": contactInfo.WebAddress,
 		    "Email": contactInfo.Email,
 		    "PhoneNumber": contactInfo.PhoneNumber,
 		    "TermsAndConditions": contactInfo.TermsAndConditions,
            "CanModify": ValidatedUser.role == POWRS.PaymentLink.Models.AccountRole.ClientAdmin.ToString()
        }
    );
)	
catch
(
    Log.Error(Exception, "", "GetContactInfo", "", null);
	BadRequest(Exception.Message);
);
