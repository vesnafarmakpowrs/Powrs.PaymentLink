Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, true);

({
    "from":Required(String(PDateFrom) like "^(0[1-9]|1[0-2])\\/(0[1-9]|[12][0-9]|3[01])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|1[0-2])\\/(0[1-9]|[12][0-9]|3[01])\\/\\d{4}$"),
    "ips": Required(Bool(PIncludeIps)),
    "cardBrands":Optional(String(PCardBrands))
}:=Posted) ??? BadRequest(Exception.Message);
try
(
    ParsedFromDate:= System.DateTime.ParseExact(PDateFrom, "MM/dd/yyyy", System.Globalization.CultureInfo.CurrentUICulture);
    ParsedToDate:= System.DateTime.ParseExact(PDateTo, "MM/dd/yyyy", System.Globalization.CultureInfo.CurrentUICulture);  

    if(ParsedFromDate >= ParsedToDate) then
    (
        Error("From date must be before to date");
    );

    includeCards:= false;
    if(exists(PCardBrands) and !System.String.IsNullOrWhiteSpace(PCardBrands)) then 
    (
        cardBrandsList:=Split(PCardBrands, ",");
        includeCards:= cardBrandsList.Length > 0;
    );

    if(includeCards == false and PIncludeIps == false) then 
    (
        Error("No payment methods selected");
    );

  creatorJid:= SessionUser.username + "@" + Gateway.Domain;
  if(includeCards and PIncludeIps) then 
  (
    array:= [POWRS.Networking.PaySpot.Consants.PaymentType.PaymentCard.ToString(), POWRS.Networking.PaySpot.Consants.PaymentType.IPSPayment.ToString()];
  )
  else if(includeCards) then 
  (
    array:= [POWRS.Networking.PaySpot.Consants.PaymentType.PaymentCard.ToString()];
  )
  else 
  (
    array:= [POWRS.Networking.PaySpot.Consants.PaymentType.IPSPayment.ToString()];
  );

  if(includeCards) then 
  (
      filteredData:= select pp.PaymentType, pp.CardBrand, pp.DateCompleted, s.VariableValues 
            from POWRS.Networking.PaySpot.Data.PayspotPayment pp 
            join NeuroFeatureTokens t on t.TokenId = pp.TokenId
            join StateMachineCurrentStates s on s.StateMachineId == pp.TokenId
            where pp.DateCompleted >= ParsedFromDate and
            pp.DateCompleted <= ParsedToDate and
	        pp.Result like "00" and
            t.CreatorJid == creatorJid and
            (pp.PaymentType in (array) or 
            pp.CardBrand in (cardBrandsList))
            order by pp.DateCompleted desc;
  )
  else 
  (
     filteredData:= select pp.PaymentType, pp.CardBrand, pp.DateCompleted, s.VariableValues 
            from POWRS.Networking.PaySpot.Data.PayspotPayment pp
            join NeuroFeatureTokens t on t.TokenId == pp.TokenId
            join StateMachineCurrentStates s on s.StateMachineId == pp.TokenId
            where pp.DateCompleted >= ParsedFromDate and
	        pp.DateCompleted <= ParsedToDate and
            pp.Result like "00" and
            t.CreatorJid = creatorJid and
            pp.PaymentType in (array) 
            order by pp.DateCompleted desc;
  );

    destroy(cardBrandsList);

    FormatedHtml:= "<!DOCTYPE html><html><head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style></head><body><table><tr><th>Referenca</th><th>Cena</th><th>Način plaćanja</th><th>Tip kartice</th><th>Datum/vreme uplate</th></tr>{{tableBody}}</table></body></html>";
    stringBuilder:= Create(System.Text.StringBuilder);

    paymentTypesDict:= {};
    paymentTypesDict[POWRS.Networking.PaySpot.Consants.PaymentType.IPSPayment.ToString()]:= "IPS";
    paymentTypesDict[POWRS.Networking.PaySpot.Consants.PaymentType.PaymentCard.ToString()]:= "Kartica";

    foreach payment in filteredData do
    (
        variables:=  payment[3];
        if(variables != null and variables.Length > 0) then 
        (
            referenceNumber:= select top 1 Value from variables where Name = "RemoteId";
            price:= select top 1 Value from variables where Name = "Price";
            currency:= select top 1 Value from variables where Name = "Currency";

            stringBuilder.Append("<tr>");

            stringBuilder.Append("<td>");
            stringBuilder.Append(referenceNumber);
            stringBuilder.Append("</td>");

            stringBuilder.Append("<td>");
            stringBuilder.Append(price.ToString("F") + currency);
            stringBuilder.Append("</td>");

            stringBuilder.Append("<td>");
            stringBuilder.Append(paymentTypesDict[payment[0]]);
            stringBuilder.Append("</td>");

            stringBuilder.Append("<td>");
            stringBuilder.Append(payment[1]);
            stringBuilder.Append("</td>");

            stringBuilder.Append("<td>");
            stringBuilder.Append(payment[2].ToString("dd-MM-yyyy HH:mm"));
            stringBuilder.Append("</td>");

            stringBuilder.Append("</tr>");
        );
    );

    FormatedHtml:= FormatedHtml.Replace("{{tableBody}}", stringBuilder.ToString());
    destroy(stringBuilder);

    fileName:= "r_" + NowUtc.ToString("MMddyyyyHHmmss");
    htmlPath:= Waher.IoTGateway.Gateway.RootFolder + fileName + ".html";
    System.IO.File.WriteAllText(htmlPath, FormatedHtml, System.Text.Encoding.UTF8);

    pdfPath:= Waher.IoTGateway.Gateway.RootFolder + fileName + ".pdf";

    ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
        "\"" + htmlPath +"\"" + " \"" +  pdfPath + "\"",
        Waher.IoTGateway.Gateway.RootFolder);

   System.IO.File.Delete(htmlPath);

   bytes:= System.IO.File.ReadAllBytes(pdfPath);

   System.IO.File.Delete(pdfPath);

   {
    	Name: fileName + ".pdf",
	    PDF: bytes
   }
)
catch
(
	Log.Error(Exception.Message, null);
	BadRequest(Exception.Message);
);