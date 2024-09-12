ValidatedUser:= Global.ValidateAgentApiToken(false, false);

logObject := ValidatedUser.username;
logEventID := "GetContactInfo.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    if(ValidatedUser.orgName != "") then
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
    );
)	
catch
(
	Log.Error("Unable to get contact info: " + Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);
