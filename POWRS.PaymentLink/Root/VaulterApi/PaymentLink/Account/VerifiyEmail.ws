Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "email":Optional(String(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "code":Required(Int(PCode)  >= 100000)    
}:=Posted) ??? BadRequest("Payload does not conform to specification.");


if !exists(Global.VerifyingNumbers) then
	Global.VerifyingNumbers:=Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));
Msg := "Email address successfully validated.";
if !exists(Global.VerifyingNumbers) or !Global.VerifyingNumbers.TryGetValue(PEmail,PCode) then 
		Msg := "No pending verification code. You have to send a new verification code.";

Global.VerifyingNumbers.Remove(PEmail);

{
  Message : Msg
}