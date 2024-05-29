﻿SessionToken:=  Global.ValidatePayoutJWT();

({
    "isFromMobile":Required(Bool(PIsFromMobile)),
	"tabId": Required(Str(PTabId))
}:=Posted) ??? BadRequest(Exception.Message);
try
(
    responseObject:= {"Success": true, "Response": null, "Message": System.String.Empty};
	if(!exists(POWRS.Payment.PaySpot.PayspotService)) then 
	(
		Error("Not configured");
	);

	IpsOnly:= false;

	if(exists(SessionToken.Claims.ipsOnly)) then 
	(
		IpsOnly:=  SessionToken.Claims.ipsOnly
	);

	ContractId:= SessionToken.Claims.contractId;
	TokenId:= SessionToken.Claims.tokenId;
	
	token:= select top 1 * from IoTBroker.NeuroFeatures.Token t where t.TokenId = TokenId;
	if(token == null) then 
	(
		BadRequest("Token does not exists");
	);

	currentState:= token.GetCurrentStateVariables();
	if(currentState.State != "AwaitingForPayment") then
	(
		Error("Payment is not available for this contract");
	);

	contractParameters:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, System.Object);
	contractParameters["Message"]:= "Vaulter";

	foreach var in currentState.VariableValues do 
	(
	 contractParameters[var.Name]:= var.Value;
	);

	contractParameters["RequestFromMobilePhone"]:= PIsFromMobile;

	legalIdentityProperties:= select top 1 Properties from LegalIdentities where Id = Token.Owner;
	identityProperties:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, Waher.Persistence.CaseInsensitiveString);

	foreach prop in legalIdentityProperties do 
	(
	 identityProperties[prop.Name]:= prop.Value;
	);

	if(!exists(Global.PayspotRequests)) then
	(
		Global.PayspotRequests:= Create(Waher.Runtime.Cache.Cache,System.String,System.String,System.Int32.MaxValue,System.TimeSpan.FromHours(0.5),System.TimeSpan.FromHours(0.5));	
	);

	Global.PayspotRequests[ContractId]:= PTabId;

	if(IpsOnly) then 
	(
		GeneratedIPSForm:= POWRS.Payment.PaySpot.PayspotService.GenerateIPSForm(contractParameters, identityProperties);
		responseObject.Response:= GeneratedIPSForm.ToDictionary();
	)
	else
	(
		responseObject.Response:= POWRS.Payment.PaySpot.PayspotService.GeneratePayspotLink(contractParameters, identityProperties);
	);
)
catch
(
 responseObject.Success:= false;
 responseObject.Message:= Exception.Message;
 Log.Error(Exception.Message, null);
);

responseObject;