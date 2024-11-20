SessionUser:= Global.ValidateAgentApiToken(true, false);

if !exists(Posted) then BadRequest("No payload.");

({
	"SuccessUrl":Required(String(PSuccessUrl)),	
	"TokenId":Required(String(PTokenId))

}:=Posted) ??? BadRequest(Exception.Message);

try
(
	
  tokenObj:=
		select top 1 * 
		from IoTBroker.NeuroFeatures.Token t
		where TokenId = PTokenId;

	if(tokenObj == null) then 
	(
		Error("Input link not valid...");
	);

	variables := tokenObj.GetCurrentStateVariables();
	
	if(variables.State != "AwaitingForPayment") then 
	(
		Error("Link is no longer valid");
	);
		
	addNoteEndpoint:= Gateway.GetUrl(":8088/AddNote/" + tokenObj.TokenId);
	namespace:= Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd");
	Post(addNoteEndpoint,<CallBackUrlUpdated xmlns=Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd") successUrl=PSuccessUrl />,{},Gateway.Certificate);

	"Success";
)
catch
(
    Log.Error(Exception, null);
    BadRequest(Exception.Message);
);
