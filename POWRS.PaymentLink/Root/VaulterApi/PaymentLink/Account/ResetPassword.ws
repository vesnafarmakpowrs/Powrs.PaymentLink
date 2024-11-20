Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "code":Required(String(PCode)),
    "password":Required(String(PPassword)),
	"userName": Required(String(PUserName))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
	if( PCode not like "[0-9]{6}" or
		Global.RegexValidation(PUserName, "UserName", "") == false or
		Global.RegexValidation(PPassword, "Password", "") == false
	) then
	(
		Error("Payload does not conform to specification.");
	);

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
	XmppServerModule.PersistenceLayer.AccountUpdated(PUserName);

	{
	}
)
catch
(
	Log.Error(Exception.Message, null);
	BadRequest(Exception.Message);
);