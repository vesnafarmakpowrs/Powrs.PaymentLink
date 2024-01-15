SessionUser:= Global.ValidateAgentApiToken(true);

try 
(
	LegalIds := select Account, Properties from LegalIdentities where State = "Approved" and Account != "OPPUser";

	list := Create(System.Collections.Generic.List, System.Object);
	foreach identity in LegalIds do
	  foreach property in identity[1] do
		 if (property.Name == "AGENT") then 
			list.Add({"Account" : identity[0]});
)
catch
(
	Log.Error(Exception, null);
	InternalServerError(Exception.Message);
);

Return(list);