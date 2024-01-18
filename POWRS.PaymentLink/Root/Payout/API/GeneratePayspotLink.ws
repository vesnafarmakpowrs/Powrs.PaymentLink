SessionToken:=  Global.ValidatePayoutJWT();

try
(
	if(!exists(POWRS.Payment.PaySpot.PayspotService.GeneratePayspotLink)) then 
	(
		Error("Not configured");
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
	  BadRequest("Payment is not available for this contract");
	);

	contractParameters:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, System.Object);
	contractParameters["Message"]:= "Vaulter";

	foreach var in currentState.VariableValues do 
	(
	 contractParameters[var.Name]:= var.Value;
	);

	legalIdentityProperties:= select top 1 Properties from LegalIdentities where Id = Token.Owner;
	identityProperties:= Create(System.Collections.Generic.Dictionary, Waher.Persistence.CaseInsensitiveString, Waher.Persistence.CaseInsensitiveString);

	foreach prop in legalIdentityProperties do 
	(
	 identityProperties[prop.Name]:= prop.Value;
	);

	link:= POWRS.Payment.PaySpot.PayspotService.GeneratePayspotLink(contractParameters, identityProperties);

	{
		link
	}
)
catch
(
 Log.Error(Exception.Message, null);
 BadRequest(Exception.Message);
);