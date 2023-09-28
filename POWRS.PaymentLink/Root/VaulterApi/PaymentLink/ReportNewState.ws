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

SendEmailOnStatusList := {"ReleaseFunds", "PaymentNotPerformed", "PaymentReimbursed","PaymentCompleted"};
SendCallBackOnStatusList := {"PaymentNotPerformed", "PaymentCompleted"};

success:= false;

if(!System.String.IsNullOrEmpty(r.CallBackUrl) && (r.Status in SendCallBackOnStatusList)) then
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

CountryCode := "EN";
if (r.Status in SendEmailOnStatusList) then
(
   contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= PContractId;

   if (contract == null) then
	Error("Contract is missing");

   ShortId := select top 1 ShortId from NeuroFeatureTokens where OwnershipContract = PContractId;
   Identities:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';
      
   ContractParams:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,System.Object);
   ContractParams.Add("Created",contract.Created.ToShortDateString());
   ContractParams.Add("ShortId",ShortId);
   foreach Parameter in contract.Parameters do 
     ContractParams.Add(Parameter.Name, Parameter.MarkdownValue);

   Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';
   IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
   IdentityProperties.Add("AgentName", Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
   IdentityProperties.Add("ORGNAME", Identity.ORGNAME);

   htmlTemplatePath:= Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + CountryCode + "\\" + r.Status + ".html";
   html:= System.IO.File.ReadAllText(htmlTemplatePath);
   htmlBuilder:= Create(System.Text.StringBuilder, html);
  
   Html := POWRS.PaymentLink.DealInfo.GetHtmlDealInfo(ContractParams, IdentityProperties,html);
     
   ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
   Config := ConfigClass.Instance;
  
   if(!System.String.IsNullOrEmpty(BuyerEmail))
   POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, BuyerEmail, "Test payment", html);

);

{    	
    "Status" : r.Status,
    "Success": success
}