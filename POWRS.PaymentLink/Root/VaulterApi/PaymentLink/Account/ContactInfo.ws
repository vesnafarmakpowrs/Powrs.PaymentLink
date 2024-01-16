Response.SetHeader("Access-Control-Allow-Origin","*");

ValidatedUser:= Global.ValidateAgentApiToken(true, false);

({
    "orgPhoneNumber": Required(Str(POrgPhoneNumber) like "\\+381\\d{8,9}"),
    "orgWebAddress": Required(Str(POrgWebAddress) like "(https?):\\/\\/([a-zA-Z0-9-]+\\.)*[a-zA-Z0-9-]+\\.[a-zA-Z]{2,}(:[0-9]+)?(\\/[^\\s]*)?"),
    "orgEmailAddress": Required(Str(POrgEmailAddress) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}")
}:=Posted) ??? BadRequest(Exception.Message);

try
(
organizationInfo:= select top 1 * from OrganizationContactInfo where Account = ValidatedUser.username;

if(organizationInfo != null) then 
(
 organizationInfo.WebAddress:= POrgWebAddress;
 organizationInfo.Email:= POrgEmailAddress;
 organizationInfo.PhoneNumber:= POrgPhoneNumber;

 Waher.Persistence.Database.Update(organizationInfo);
)
else
(
 insert into OrganizationContactInfo 
    (
     "Account", 
     "WebAddress",
     "Email", 
     "PhoneNumber"
    )
    values 
    (
     ValidatedUser.username,
     POrgWebAddress,
     POrgEmailAddress,
     POrgPhoneNumber
    );
 );

 {
 }
)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
