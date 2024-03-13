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

    payspotPayments:= Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Data.PayspotPayment);
    paymentTokens:= Create(System.Collections.Generic.List, System.Object);

    if(PIncludeIps) then 
    (
        list:= select * from POWRS.Networking.PaySpot.Data.PayspotPayment where DateCompleted >= ParsedFromDate and DateCompleted <= ParsedToDate and PaymentType = POWRS.Networking.PaySpot.Consants.PaymentType.IPSPayment.ToString();
        foreach item in list do 
        (
            payspotPayments.Add(item);
        );

        destroy(list);
        destroy(item);
    );

    if(includeCards) then 
    (
        list:= select * from POWRS.Networking.PaySpot.Data.PayspotPayment where DateCompleted >= ParsedFromDate and DateCompleted <= ParsedToDate and PaymentType = POWRS.Networking.PaySpot.Consants.PaymentType.PaymentCard.ToString();
        foreach item in list do 
        (
            if(item.CardBrand in cardBrandsList) then 
            (
               payspotPayments.Add(item);
            );
        );

        destroy(list);
        destroy(item);
    );

    creatorJid:= SessionUser.username + "@" + Gateway.Domain;
    foreach payment in payspotPayments do
    (           
            token:= select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId = payment.TokenId and CreatorJid = creatorJid;
            if(token != null) then 
            (
                paymentTokens.Add({
                   "currentState":  token.GetCurrentStateVariables(),
                   "creator": token.CreatorJid,
                   "cardBrand": payment.CardBrand,
                   "paymentType": payment.PaymentType
                });
            );
    );

    destroy(payspotPayments);
    destroy(currentState);
    destroy(cardBrandsList);

    FormatedHtml:= "<!DOCTYPE html><html><head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style></head><body><table><tr><th>Referenca</th><th>Cena</th><th>Način plaćanja</th><th>Tip kartice</th></tr>{{tableBody}}</table></body></html>";
    stringBuilder:= Create(System.Text.StringBuilder);

    paymentTypesDict:= {};
    paymentTypesDict[POWRS.Networking.PaySpot.Consants.PaymentType.IPSPayment.ToString()]:= "IPS";
    paymentTypesDict[POWRS.Networking.PaySpot.Consants.PaymentType.PaymentCard.ToString()]:= "Kartica";

    foreach token in paymentTokens do
    (
        variables:=  token.currentState.VariableValues;
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
            stringBuilder.Append(paymentTypesDict[token.paymentType]);
            stringBuilder.Append("</td>");

            stringBuilder.Append("<td>");
            stringBuilder.Append(token.cardBrand);
            stringBuilder.Append("</td>");

            stringBuilder.Append("</tr>");
        );
    );

    FormatedHtml:= FormatedHtml.Replace("{{tableBody}}", stringBuilder.ToString());

    destroy(token);
    destroy(paymentTokens);
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