

SessionUser:= Global.ValidateAgentApiToken(true, false);

({
    "year":Required(String(PYear) like "[0-9]{4}"),
	"agents":Optional(String(PAgents) like "[\\p{L}\\p{N},]")
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try(
	Agents:= PAgents ?? "";
	
	if (IsEmpty(Agents)) then (
		LegalIds:= select Account, Properties from LegalIdentities where State = "Approved" and Account != "OPPUser";
		foreach identity in LegalIds do (
			foreach property in identity[1] do (
				if (property.Name == "AGENT") then (
					Agents += IsEmpty(Agents) ? identity[0] : "," + identity[0];
				);
			);
		);
	);
	
	AgentArray:= Split(Agents, ",");

	mSelect:= Select ContractId, OrderId, OrderReference, TokenId, Result, PayspotTransactionId, DateCompleted
		from PayspotPayments
		where Result = "00"
			and DateCompleted >= Create(System.DateTime, Integer(PYear), 01, 01)
			and DateCompleted < Create(System.DateTime, Integer(PYear) + 1, 01, 01);
	
	mSelect2:= select mSelect.ContractId, mSelect.OrderId, mSelect.OrderReference, mSelect.TokenId, mSelect.Result, mSelect.PayspotTransactionId, mSelect.DateCompleted, Contracts.Account
		from mSelect
			inner join Contracts on mSelect.ContractId = Contracts.ContractId;
			
	mSelect3:= select ContractId, OrderId, OrderReference, TokenId, Result, PayspotTransactionId, DateCompleted, Account
		from mSelect2
		where Account in (AgentArray);
	
	mReturnData:=select Max(Month(DateCompleted)) as "Month", Account, Count(*) as "Cnt"
		from mSelect3
		group by Month(DateCompleted), Account;
		
)
catch(
	Log.Error(Exception, null);
	InternalServerError(Exception.Message);
);

return(mReturnData);