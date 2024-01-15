Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "year":Required(String(PYear) like "[0-9]{4}") 
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

SessionUser:= Global.ValidateAgentApiToken(true);

try(
	sqlData := select Max(Month(Created)) as 'Month'
				   , count(*) as 'Cnt'
				from LegalIdentities
				where Year(Created) = Integer(PYear)
					and State = 'Approved'
				group by Month(Created);
				
	parsedData := select * from sqlData;
)
catch
(
	Log.Error(Exception, null);
	BadRequest(Exception.Message);
);

return(parsedData);