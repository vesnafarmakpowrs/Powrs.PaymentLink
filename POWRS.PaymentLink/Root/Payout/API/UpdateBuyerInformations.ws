SessionToken:=  Global.ValidatePayoutJWT();

({
    "firstName":Required(Bool(PFirstName)),
	"lastName": Required(Str(PLastName)),
	"city": Required(Str(PCity)),
	"phoneNumber": Required(Str(PPhoneNumber)),
	"email": Required(Str(PEmail)),
	"address": Required(Str(PAddress))
}:=Posted) ??? BadRequest(Exception.Message);

if(!exists(SessionToken.tokenId) or System.String.IsNullOrEmpty(SessionToken.tokenId)) then
(
	Forbidden();
);
errors:= Create(System.Collections.Generic.List, System.String);

if(!Global.RegexValidation(PFirstName, "PersonFirstLastName", "")) then 
(
	errors.Add("firstName");
);
if(!Global.RegexValidation(PLastName, "PersonFirstLastName", "")) then 
(
	errors.Add("lastName");
);
if(!Global.RegexValidation(PPhoneNumber, "PhoneNumber", "")) then 
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
	errors.Add("address");
);

if(errors.Count > 0) then 
(
	BadRequest(errors);
);

addNoteEndpoint:= Gateway.GetUrl(":8088/AddNote/" + SessionToken.tokenId);
	            namespace:= "https://" + Gateway.Domain + "/Downloads/EscrowPaylinkRS.xsd";
	            Post(addNoteEndpoint ,<UpdateBuyerInformations xmlns=namespace fullName=(PFirstName + " " + PLastName) city=PCity phoneNumber=PPhoneNumber email=PEmail address=PAddress    />,{},Waher.IoTGateway.Gateway.Certificate);

{
}

