Response.SetHeader("Access-Control-Allow-Origin","*");
SessionUser:= Global.ValidateAgentApiToken(true, true);

({
    "from":Required(String(PDateFrom) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "to":Required(String(PDateTo) like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"),
    "paymentType": Optional(String(PPaymentType)),
    "cardBrands":Optional(String(PCardBrands)), 
    "filterType": Optional(String(PFitlerType))
}:=Posted) ??? BadRequest(Exception.Message);

logObject := SessionUser.username;
logEventID := "GenerateTransactionsReport.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    SaveHtmlAsPdf(htmlContent, fileName):= 
    (
		htmlPath:= Waher.IoTGateway.Gateway.RootFolder + fileName + ".html";
		System.IO.File.WriteAllText(htmlPath, htmlContent, System.Text.Encoding.UTF8);
		pdfPath:= Waher.IoTGateway.Gateway.RootFolder + fileName + ".pdf";

		ShellExecute("\"C:\\Program Files\\wkhtmltopdf\\bin\\wkhtmltopdf.exe\"", 
			"\"" + htmlPath +"\"" + " \"" +  pdfPath + "\"",
			Waher.IoTGateway.Gateway.RootFolder);

        System.IO.File.Delete(htmlPath);
        bytes:= System.IO.File.ReadAllBytes(pdfPath);
        System.IO.File.Delete(pdfPath);

        {
            {
    	        Name: fileName + ".pdf",
	            PDF: bytes
            }
        }
    );

    stringBuilder:= Create(System.Text.StringBuilder);
    headers:= ["Referenca", "Cena", "Način plaćanja", "Tip kartice", "Datum/vreme uplate", "Očekivani datum isplate", "Datum isplate", "Iznos isplate"];
    
    stringBuilder.Append("<tr>");
    foreach (h in headers) do 
    (
        stringBuilder.Append("<th>");
        stringBuilder.Append(h);
        stringBuilder.Append("</th>");
    );
    stringBuilder.Append("</tr>");

    FormatedHtml:= "<!DOCTYPE html><html><head><style>table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd;text-align: left;padding: 8px;}tr:nth-child(even) {background-color: #dddddd;}</style></head><body><table>{{tableHeader}}{{tableBody}}</table></body></html>";   
    FormatedHtml:= FormatedHtml.Replace("{{tableHeader}}", stringBuilder.ToString());
    stringBuilder.Clear();

    paymentTypesDict:= {};
    paymentTypesDict[POWRS.Networking.PaySpot.Consants.PaymentType.IPSPayment.ToString()]:= "IPS";
    paymentTypesDict[POWRS.Networking.PaySpot.Consants.PaymentType.PaymentCard.ToString()]:= "Kartica";

    PPaymentType := PPaymentType ?? "";
	PCardBrands := PCardBrands ?? "";
    PFitlerType := PFitlerType ?? "Report";
    payments:= GetAgentSuccessfullTransactions(SessionUser.username, PDateFrom, PDateTo, PPaymentType, PCardBrands, PFitlerType);
    
	foreach payment in payments do
    (
		stringBuilder.Append("<tr>");

		stringBuilder.Append("<td>");
		stringBuilder.Append(payment.RemoteId);
		stringBuilder.Append("</td>");

		stringBuilder.Append("<td>");
		stringBuilder.Append(payment.Amount.ToString("F") + payment.Currency);
		stringBuilder.Append("</td>");

		stringBuilder.Append("<td>");
		stringBuilder.Append(paymentTypesDict[payment.PaymentType]);
		stringBuilder.Append("</td>");

		stringBuilder.Append("<td>");
		stringBuilder.Append(payment.CardBrand);
		stringBuilder.Append("</td>");

		stringBuilder.Append("<td>");
		stringBuilder.Append(payment.DateCompleted.ToLocalTime().ToString("dd/MM/yyyy HH:mm"));
		stringBuilder.Append("</td>");

		stringBuilder.Append("<td>");
		if(payment.ExpectedPayoutDate != null) then
		(
			 stringBuilder.Append(payment.ExpectedPayoutDate.ToLocalTime().ToString("dd/MM/yyyy"));
		)
		else 
		(
			stringBuilder.Append("---");
		);           
		stringBuilder.Append("</td>");
		
		stringBuilder.Append("<td>");
		if(payment.PayoutDate != null and payment.PayoutDate.ToLocalTime().ToString("dd/MM/yyyy") != "01/01/0001") then
		(
			 stringBuilder.Append(payment.PayoutDate.ToLocalTime().ToString("dd/MM/yyyy"));
		)
		else 
		(
			stringBuilder.Append("---");
		);           
		stringBuilder.Append("</td>");
		
		stringBuilder.Append("<td>");
		if(payment.SellerRecivedAmount != null and payment.SellerRecivedAmount > 0)then
		(
			stringBuilder.Append(payment.SellerRecivedAmount.ToString("F") + payment.Currency);
		)
		else 
		(
			stringBuilder.Append("---");
		);
		stringBuilder.Append("</td>");		

		stringBuilder.Append("</tr>");
    );

    FormatedHtml:= FormatedHtml.Replace("{{tableBody}}", stringBuilder.ToString());
    destroy(stringBuilder);

    fileName:= "r_" + NowUtc.ToString("MMddyyyyHHmmss");
    SaveHtmlAsPdf(FormatedHtml, fileName);
)
catch
(
	Log.Error("Unable to generate report: " + Exception.Message, logObject, logActor, logEventID, null);
	BadRequest(Exception.Message);
);