Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "email":Optional(String(PEmail)),
    "code":Required(Int(PCode))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
    if(Global.RegexValidation(PEmail, "Email", "") == false or
        PCode < 100000
    ) then
	(
		Error("Payload does not conform to specification.");
	);

    remoteEndpoint:= Split(Request.RemoteEndPoint, ":")[0];
    
    if !exists(Global.VerifyingEmailIP) then 
    (
        Global.VerifyingEmailIP :=Create(Waher.Runtime.Cache.Cache,System.String,System.Int32,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));
    );
    
    value := 0;
    maxAttemptsInHour := 10;
    
    Global.VerifyingEmailIP.TryGetValue(remoteEndpoint , value);
    
    if value > 0 then value := value + 1;
    
    if value > maxAttemptsInHour then
    (
        Error('Too many attempts. Try again in a hour.');
    ) 

    Global.VerifyingEmailIP.Add(remoteEndpoint, value);
    
    Code:= 0;
    if (!exists(Code:= Global.VerifyingNumbers[PEmail])) then
    (
        Error("No pending verification code. You have to send a new verification code.");
    );

    if(Code < 0) then 
    (
       Error("Email already verified.");
    );
    
    if PCode != Code then 
    (
        Error("Code does not match.");
    );
       
    Global.VerifyingNumbers[PEmail]:= -1;
    
    {
      Message : "ok"
    }
)
catch
(
    Log.Informational(Exception.Message, null);
    BadRequest("Unable to verify email: " + Exception.Message);
);