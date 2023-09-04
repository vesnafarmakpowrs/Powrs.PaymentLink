if !exists(Posted) then BadRequest("No payload.");

({
   "stateMachineId":Optional(String(PMachineId)),
   "contractId": Optional(String(PContractId)),
   "countryCode":Required(String(PCountryCode))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= PContractId;

ShortId := select top 1 ShortId from NeuroFeatureTokens where TokenId= PMachineId;
Identities:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = contract.Account And State = 'Approved';

AgentName := "";
OrgName := "";
foreach I in Identities do
(
 AgentName := I.FIRST + " " + I.MIDDLE + " " + I.LAST;
 OrgName  := I.ORGNAME;
);

SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;
SellerId := SellerName.Substring(0,3).ToUpper(); 

 fileName:= SellerId + ShortId + ".pdf";
 url:= Waher.IoTGateway.Gateway.GetUrl("/PDF/DoneDeals/"+ fileName);

 htmlTemplatePath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\purchase_agreement.html";
 htmlToGeneratePath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\" + PContractId + ".html";

 pdfPath:= Waher.IoTGateway.Gateway.RootFolder + "\\Payout\\HtmlTemplates\\" + PCountryCode + "\\" + fileName;

 html:= System.IO.File.ReadAllText(htmlTemplatePath);
 htmlBuilder:= Create(System.Text.StringBuilder, html);

Value := 0;
EscrowFee := 0;
 foreach Parameter in (contract.Parameters ?? []) do 
 (
     Parameter.Name like "Value" ?  Value := System.String.IsNullOrEmpty(Parameter.MarkdownValue)? 0 :Parameter.MarkdownValue ;
     Parameter.Name like "EscrowFee" ?  EscrowFee := System.String.IsNullOrEmpty(Parameter.MarkdownValue)? 0 :Parameter.MarkdownValue ;
     Parameter.Name like "Title" ?   htmlBuilder:= htmlBuilder.Replace("{{purchased_product_name}}",  Parameter.MarkdownValue);
     Parameter.Name like "BuyerFullName" ?   htmlBuilder:= htmlBuilder.Replace("{{buyer_name}}",  Parameter.MarkdownValue);
     Parameter.Name like "Currency" ?   htmlBuilder:= htmlBuilder.Replace("{{currency}}",  Parameter.MarkdownValue);
     Parameter.Name like "DealDoneDate" ?   htmlBuilder:= htmlBuilder.Replace("{{issue_date}}",  Parameter.MarkdownValue);
     Parameter.Name like "DeliveryDate" ?   htmlBuilder:= htmlBuilder.Replace("{{delivery_date}}",  Parameter.Value.ToShortDateString());
   );

AmountToPay:= 0;
AmountToPay :=  Int(Value) + Int(EscrowFee);

htmlBuilder:= htmlBuilder.Replace("{{value}}",  Value.ToString());
htmlBuilder:= htmlBuilder.Replace("{{escrow_fee}}",  EscrowFee.ToString());
htmlBuilder:= htmlBuilder.Replace("{{amount_paid}}",  AmountToPay.ToString());
htmlBuilder:= htmlBuilder.Replace("{{seller_name}}",  SellerName);
htmlBuilder:= htmlBuilder.Replace("{{seller_id}}",  SellerId);
htmlBuilder:= htmlBuilder.Replace("{{short_id}}",  ShortId);
htmlBuilder:= htmlBuilder.Replace("{{issue_date}}", contract.Created.ToShortDateString());

 System.IO.File.WriteAllText(htmlToGeneratePath, htmlBuilder.ToString(), System.Text.Encoding.UTF8);

 ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
 "\"" + htmlToGeneratePath +"\"" + " \"" +  pdfPath + "\"",
 "C:\\ProgramData\\IoT Gateway\\Root\\Payout\\HtmlTemplates");

	
{
	Name: fileName,
	Url: url
}
