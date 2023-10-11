if !exists(Posted) then BadRequest("No payload.");

({
   "contractId": Optional(String(PContractId)),
   "countryCode":Required(String(PCountryCode))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

   contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= PContractId;

   if (contract == null) then
	Error("Contract is missing");

   ShortId := select top 1 ShortId from NeuroFeatureTokens where OwnershipContract = PContractId;
      
   ContractParams:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,System.Object);
   ContractParams.Add("Created",contract.Created.ToShortDateString());
   ContractParams.Add("ShortId",ShortId);
   foreach Parameter in contract.Parameters do
     Parameter.ObjectValue != null ? ContractParams.Add(Parameter.Name, Parameter.ObjectValue);

   Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';
   IdentityProperties:= Create(System.Collections.Generic.Dictionary,CaseInsensitiveString,CaseInsensitiveString);
   foreach Parameter in Identity.Parameters do 
     Parameter.ObjectValue != null ? ContractParams.Add(Parameter.Name, Parameter.ObjectValue);
   IdentityProperties.Add("AgentName", Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
   IdentityProperties.Add("ORGNAME", Identity.ORGNAME );
   
   htmlTemplatePath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\purchase_agreement.html"; 
   html:= System.IO.File.ReadAllText(htmlTemplatePath);
   FormatedHtml := POWRS.PaymentLink.DealInfo.GetHtmlDealInfo(ContractParams, IdentityProperties,html);
   
   htmlToGeneratePath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\" + PContractId + ".html";
   
   fileName:= POWRS.PaymentLink.DealInfo.GetInvoiceNo(IdentityProperties, ShortId) + ".pdf";
   url:= Waher.IoTGateway.Gateway.GetUrl("/PDF/DoneDeals/"+ fileName);

   htmlToGeneratePath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\" + PContractId + ".html";
   System.IO.File.WriteAllText(htmlToGeneratePath, FormatedHtml, System.Text.Encoding.UTF8);
   
   pdfPath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\" + fileName;
   ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
   "\"" + htmlToGeneratePath +"\"" + " \"" +  pdfPath + "\"",
   Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\");

   bytes:= System.IO.File.ReadAllBytes(pdfPath);

   System.IO.File.Delete(htmlToGeneratePath);
   System.IO.File.Delete(pdfPath);
	
{
	Name: fileName,
	PDF: bytes
}
