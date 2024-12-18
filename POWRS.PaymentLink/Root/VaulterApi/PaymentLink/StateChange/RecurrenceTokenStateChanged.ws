AuthenticateMutualTls(Request,Waher.Security.Users.Users.Source,128);

logObject := "RecurrenceTokenStateChanged";
logEventID := "RecurrenceTokenStateChanged.ws";
logActor := Request.RemoteEndPoint;
try
(
		if(!exists(Posted) then 
		(
			BadRequest("Request body could not be empty");
		);
        if !exists(Posted) then BadRequest("No payload.");
        request:= Request.DecodeData();

