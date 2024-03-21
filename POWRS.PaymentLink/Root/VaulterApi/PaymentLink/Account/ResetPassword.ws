Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "code":Required(String(PCode) like "[0-9]{6}"),
    "password":Required(String(PPassword) like "^(?=.*[\\p{Ll}])(?=.*[\\p{Lu}])(?=.*[\\p{N}])(?=.*[^\\p{L}\\p{N}])[^\\s]{8,}$"),
	"userName": Required(String(PUserName) like "^[\\p{L}\\p{N}]{8,20}$")
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
	account:= select top 1 * from BrokerAccounts where UserName = PUserName;
	if(account == null) then 
	(
		Error("No account with given username");
	);

	passwordResetRequest:= null;
	if(!exists(Global.PasswordResetRequests.TryGetValue(PUserName, passwordResetRequest)) or passwordResetRequest == null) then 
	(
		Error("No change password request existing in the system.");
	);

	if(passwordResetRequest.ValidUntil <= NowUtc) then 
	(
		Error("Code is expired. Send new code.");
	);

	if(Str(passwordResetRequest.VerificationCode) != PCode) then 
	(
		Error("Code does not match.");
	);
	
	update BrokerAccounts set Password = PPassword where UserName == PUserName;

	{
	}
)
catch
(
	BadRequest(Exception.Message);
	Log.Error(Exception.Message, null);
);