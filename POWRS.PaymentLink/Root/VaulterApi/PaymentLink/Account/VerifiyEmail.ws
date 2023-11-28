Response.SetHeader("Access-Control-Allow-Origin","*");

({
    "email":Optional(String(PEmail) like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,}"),
    "code":Required(Int(PCode)  >= 100000)    
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

PrevCode:=0;
remoteEndpoint:= Request.RemoteEndPoint.Split(':', null)[0];

if !exists(Global.VerifyingEmailIP) then
  Global.VerifyingEmailIP :=Create(Waher.Runtime.Cache.Cache,System.String,System.Int32,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));

message := "";
value := 0;
maxAttemptsInHour := 10;

Global.VerifyingEmailIP.TryGetValue(remoteEndpoint , value);

if value > 0 then value := value + 1;

if value > maxAttemptsInHour then 
  BadRequest('Too many attempts. Try again in a hour.')
else
  Global.VerifyingEmailIP.Add(remoteEndpoint, value);

if !exists(Global.VerifyingNumbers) then
	Global.VerifyingNumbers:=Create(Waher.Runtime.Cache.Cache,System.String,System.Double,System.Int32.MaxValue,System.TimeSpan.MaxValue,System.TimeSpan.FromHours(1));

Msg := "Email address successfully validated.";

Code := 0;
if !exists(Global.VerifyingNumbers) or !Global.VerifyingNumbers.TryGetValue(PEmail,Code) then 
   Msg := "No pending verification code. You have to send a new verification code.";

if PCode != Code then Msg := "Invalid code";
   
Global.VerifyingNumbers.Remove(PEmail);

{
  Message : Msg
}