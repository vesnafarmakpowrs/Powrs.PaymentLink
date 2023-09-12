remoteEndpoint:= Request.RemoteEndPoint.Split(':', null)[0];
blocked:= select Blocked from RemoteEndpoints where Endpoint = remoteEndpoint;

if(blocked != null && blocked == true) then 
(
 Sleep(30000);
 NotFound("");
);

if !exists(Posted) then BadRequest("No payload.");
r:= Request.DecodeData();
if(!exists(r.Status) || !exists(r.ContractId) || !exists(r.CallBackUrl)) then
(
  BadRequest("Payload does not conform to specification.");
);

if(System.String.IsNullOrEmpty(r.Status) || System.String.IsNullOrEmpty(r.ContractId)) then 
(
 BadRequest("Payload does not conform to specification.");
);

success:= false;
if(!System.String.IsNullOrEmpty(r.CallBackUrl)) then
(
 Log.Informational("Sending state update request to: " + r.CallBackUrl + " State: " + r.Status, null);
 POST(r.CallBackUrl,
                 {
	           "status": r.Status
                  },
		  {
	           "Accept" : "application/json"
                  });
 success:= true;
 Log.Informational("Sending state update request finished to: " + r.CallBackUrl + " State: " + r.Status, null);
);

{    	
    "Status" : r.Status,
    "Success": success
}