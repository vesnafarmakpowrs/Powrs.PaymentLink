    Response.SetHeader("Access-Control-Allow-Origin","*");

    signatureKey:= GetSetting("POWRS.PaymentLink.ApiIntegrationSignatureKey","");
    PaySpotApiURL:= GetSetting("POWRS.PaymentLink.PayspotAuthorizationResponseUrl","");

    if(System.String.IsNullOrWhiteSpace(signatureKey.Trim()) or System.String.IsNullOrWhiteSpace(PaySpotApiURL.Trim())) then 
    (
        InternalServerError("Not configured correctly.");
    ); 
    
    header:= null;  
    Request.Header.TryGetHeaderField("X-Signature", header);
    if(header == null) then 
    (
        Forbidden("Unathorized access");
    );
    if(System.String.IsNullOrWhiteSpace(header.Value)) then
    (
        Forbidden("Unathorized access");
    );
    if(!exists(innerXml:= Posted.InnerXml)) then 
    (
	    BadRequest("Not valid xml");
    );
try
(
    logObject:= "";
    logActor:= "AuthorizationResponse.ws";
    logEventId:= Split(Request.RemoteEndPoint, ":")[0];

    myHMac := Base64Encode(Sha2_512(Utf8Encode(innerXml + signatureKey)));
    if(header.Value != myHMac) then
    (
        Error("Invalid signature");
    );

    SendRequestToPayspot(PaySpotApiURL, Data, Signature):=
    (
        try
        (       
            Post(PaySpotApiURL, Data, {"X-Signature": Signature, "Accept": "*/*" });
        )
        catch
        (
            Log.Error("Error during AuthorizationResponse request to: " + PaySpotApiURL + " .Message: " + Exception.Message, logObject, logActor, logEventId, null);
        );  
    );

    Background(SendRequestToPayspot(PaySpotApiURL, Posted, myHMac));
)
catch
(
	Log.Error(Exception.Message, logObject, logActor, logEventId, null);
	Forbidden(Exception.Message);
);

{
}