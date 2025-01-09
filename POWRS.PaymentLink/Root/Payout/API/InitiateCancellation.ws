SessionToken:=  Global.ValidatePayoutJWT();

try
(
    responseObject:= {"Success": true, "Response": null, "Message": System.String.Empty};
	if(!exists(POWRS.Payment.PaySpot.PayspotService)) then
	(
		Error("Not configured");
	);

	TokenId:= SessionToken.Claims.tokenId;
	tokenVariablesResponse:= Global.GetTokenVariables(TokenId, ["AwaitingCardRegistration", "AwaitingNextPayment"], false);

	addNoteEndpoint:= Gateway.GetUrl(":8088/AddNote/" + TokenId);
	namespace:= Gateway.GetUrl("/Downloads/EscrowPaylinkRS.xsd");

    xmlNote := <CancelPayment xmlns=namespace />;
    xmlNoteResponse := POST(addNoteEndpoint,xmlNote,
		          {"Accept" : "application/json"}, Gateway.Certificate);
)
catch
(
 responseObject.Success:= false;
 responseObject.Message:= Exception.Message;
 Log.Error(Exception.Message, null);
);

responseObject;