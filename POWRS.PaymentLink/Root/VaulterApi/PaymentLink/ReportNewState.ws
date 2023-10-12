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

SendEmailOnStatusList := {"ServiceDelivered", "PaymentCanceled", "PaymentCompleted"};
SendCallBackOnStatusList := {"PaymentNotPerformed", "PaymentCompleted"};

success:= false;

if(!System.String.IsNullOrEmpty(r.CallBackUrl) && (r.Status in SendCallBackOnStatusList)) then
(
  try
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
    )catch
       Log.Informational("Sending state update request finished  to: " + r.CallBackUrl + "failed",null);
  
);

CountryCode := "SE";
if (r.Status in SendEmailOnStatusList) then
(
 
   contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= r.ContractId;

   if (contract == null) then
	Error("Contract is missing");

   ShortId := select top 1 ShortId from NeuroFeatureTokens where OwnershipContract = r.ContractId;
      
   ContractParams:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,System.Object);
   ContractParams.Add("Created",contract.Created.ToShortDateString());
   ContractParams.Add("ShortId",ShortId);
   ContractParams.Add("ContractId",r.ContractId.ToString());
   foreach Parameter in contract.Parameters do 
    Parameter.ObjectValue != null ? ContractParams.Add(Parameter.Name, Parameter.ObjectValue);

   Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';
   IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
   IdentityProperties.Add("AgentName", Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
   IdentityProperties.Add("ORGNAME", Identity.ORGNAME);
   IdentityProperties.Add("CountryCode", CountryCode);
   IdentityProperties.Add("Domain", Gateway.Domain);

   htmlTemplateRoot := Waher.IoTGateway.Gateway.RootFolder + "Payout\\HtmlTemplates\\" + CountryCode + "\\";

   htmlTemplatePath:= htmlTemplateRoot + r.Status + ".html";
   html:= System.IO.File.ReadAllText(htmlTemplatePath);
  
   FormatedHtml := POWRS.PaymentLink.DealInfo.GetHtmlDealInfo(ContractParams, IdentityProperties,html);
	
   if Contains(FormatedHtml,"{{purchase_agreement}}") then
   (
     htmlTemplatePath:= htmlTemplateRoot + "purchase_agreement.html"; 
     html:= System.IO.File.ReadAllText(htmlTemplatePath);
     FormatedHtml := POWRS.PaymentLink.DealInfo.GetHtmlDealInfo(ContractParams, IdentityProperties,html);
   
     htmlToGeneratePath:= htmlTemplateRoot + r.ContractId + ".html";
   
     fileName:= POWRS.PaymentLink.DealInfo.GetInvoiceNo(IdentityProperties, ShortId) + ".pdf";
     url:= Waher.IoTGateway.Gateway.GetUrl("/PDF/DoneDeals/"+ fileName);

     htmlToGeneratePath:= htmlTemplateRoot + r.ContractId + ".html";
     System.IO.File.WriteAllText(htmlToGeneratePath, FormatedHtml, System.Text.Encoding.UTF8);
   
     pdfPath:= htmlTemplateRoot + fileName;
     ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
     "\"" + htmlToGeneratePath +"\"" + " \"" +  pdfPath + "\"", htmlTemplateRoot);

     bytes:= System.IO.File.ReadAllBytes(pdfPath);

     System.IO.File.Delete(htmlToGeneratePath);
     System.IO.File.Delete(pdfPath);

     Replace(FormatedHtml,"{{purchase_agreement}}",bytes);

   );

   ConfigClass:=Waher.Service.IoTBroker.Setup.RelayConfiguration;
   Config := ConfigClass.Instance;
   POWRS.PaymentLink.MailSender.SendHtmlMail(Config.Host, Int(Config.Port), Config.UserName, Config.Password, ContractParams["BuyerEmail"].ToString(), "Vaulter", FormatedHtml);
   
);

{    	
    "Status" : r.Status,
    "Success": success
}