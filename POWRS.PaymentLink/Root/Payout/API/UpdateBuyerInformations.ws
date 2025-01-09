SessionToken:=  Global.ValidatePayoutJWT();

({
    "fullName":Required(Str(PFullName)),
	"city": Required(Str(PCity)),
	"email": Required(Str(PEmail)),
	"address": Required(Str(PAddress)),
	"phoneNumber": Optional(Str(PPhoneNumber))
}:=Posted) ??? BadRequest(Exception.Message);

if(!exists(SessionToken.Claims.tokenId) or System.String.IsNullOrEmpty(SessionToken.Claims.tokenId)) then
(
	Forbidden("");
);

errors:= Create(System.Collections.Generic.List, System.String);

if(!Global.RegexValidation(PFullName, "FullName", "")) then 
(
	errors.Add("fullName");
);
if(!exists(PPhoneNumber)) then 
(
	PPhoneNumber:= "";
);
if(PPhoneNumber != "" and !Global.RegexValidation(PPhoneNumber, "PhoneNumber", "")) then 
(
	errors.Add("phoneNumber");
);
if(!Global.RegexValidation(PEmail, "Email", "")) then 
(
	errors.Add("email");
);
if(!Global.RegexValidation(PAddress, "Address", "")) then 
(
	errors.Add("address");
);
if(!Global.RegexValidation(PCity, "City", "")) then
(
	errors.Add("city");
);

if(errors.Count > 0) then 
(
	BadRequest(errors);
);

addNoteEndpoint:= Gateway.GetUrl(":8088/AddNote/" + SessionToken.Claims.tokenId);
namespace:= Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd");
Post(addNoteEndpoint ,<UpdateBuyerInformations xmlns=namespace fullName=PFullName city=PCity phoneNumber=PPhoneNumber email=PEmail address=PAddress />,{},Waher.IoTGateway.Gateway.Certificate);

{
}

