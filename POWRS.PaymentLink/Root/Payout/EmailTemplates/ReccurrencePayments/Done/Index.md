Title: Payment Link
Description: Payment Link.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
Pragma: no-cache
Expires: 0
viewport : Width=device-width, initial-scale=1
Parameter: TokenId

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container" style="width:100%;max-width:600px;margin:0 auto; padding:20px; background-color: #ffffff; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); font-family:arial;">
<div class="content">

{{
Token:=select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId=TokenId;
if !exists(Token) then
(
  NotFound("");
);

Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Id = Token.Owner;
if(!exists(Identity.ORGNAME)) then 
(
	NotFound("Organization name not found");
);

CompanyInfo := select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = Identity.ORGNAME;

if(CompanyInfo == null) then 
(
	NotFound("CompanyInfo not found");
);
if(!CompanyInfo.IsValid()) then 
(
	NotFound("CompanyInfo not valid");
);

if Token.HasStateMachine then
(
    CurrentState:=Token.GetCurrentStateVariables();
)else 
(
	NotFound("");
);

Variables:= CurrentState.VariableValues;
BuyerName:= select top 1 Value from Variables where Name = "Buyer";
Title:= select top 1 Value from Variables where Name = "Title";
SellerName:= select top 1 Value from Variables where Name = "SellerName";
CancellationReason:= select top 1 Value from Variables where Name = "CancellationReason";
Country:= select top 1 Value from Variables where Name = "Country";
Currency:= select top 1 Value from Variables where Name = "Currency";
Payments:= select * from PayspotPayments where MaskedPan != null and MaskedPan != "";

	 	]]<div class="header" style="text-align: center; padding: 10px;">
            <img src="data:image/png;base64,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" />
        </div>
        <div class="details">
            <div class="transaction-status">
				<div id="status" style="color:green; border-bottom: green 2px solid; padding-bottom:0;">
					 <h2 style="margin: 0.5em 0em;">Completed</h2>
				</div>
				<div id="description">
					<p>Hello ((BuyerName )), we are happy to inform you that all due payments for  <i>((Title ))</i> performed by the company <i>((SellerName ))</i> are now completed.
					<p>All the details about completed/failed transactions will be visible in the table below. If you have any question please contact seller directly.</p>
				</div>
								<div style="margin-bottom:20px;">
					<table style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; border: 1px solid #ddd;">
					<caption style="font-size: 16px; font-weight: bold; margin-bottom: 10px;">All transactions</caption>
					<thead>
						<tr>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">MaskedPan</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">Brand</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">Amount</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">Authorization</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">OrderId</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">Date</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">Status</th>
						</tr>
					</thead>
					<tbody>[[;
						foreach(item in Payments) do 
						(
							status:= item.RefundedAmount > 0 ? "Refunded" : (item.Result == "00" ? "Completed" : "Failed");
							color:= status == "Refunded" ? "orange" : (status == "Completed" ? "green" : "red");
						]]<tr>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.MaskedPan ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.CardBrand ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.Amount )) ((Currency ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.AuthNumber))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.OrderId))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.DateCompleted.ToString("dd-MM-yyyy") ))</td>
							<td style="padding: 8px; border: 1px solid #ddd; color: ((color ))">((item.RefundedAmount > 0 ? "Refunded" : (item.Result == "00" ? "Completed" : "Failed") ))</td>
						</tr>[[;
						);
						]]</tbody>
					</table>
				</div>
			</div>
		</div>
		<div>
			<p>If you want to know more details about this email and contract itself, please contact the seller directly at the phone number: <a href="tel:((CompanyInfo.PhoneNumber ))">((CompanyInfo.PhoneNumber ))</a> or mail: <a href="mailto:((CompanyInfo.Email ))">((CompanyInfo.Email ))</a> </p>
		</div>
		<div style="text-align: center;">
		<i><p style="color: gray; font-size: 0.8em">We are sad to say goodbye, we hope that you had good experience from using our platform.</p>
		<p style="color: gray;  font-size: 0.8em">Thank you for using Vaulter.</p></i>
		</div>
		 <div class="footer"style="text-align: center;">
            <span class="footer-text" style="display: block;color: gray; font-size: 0.8em; text-align:center;"> POWRS D.O.O. BEOGRAD, Srbija</span>
            <span class="footer-text" style="display: block;color: gray; font-size: 0.8em; text-align:center;">©2021 - ((Now.Year )) POWRS</span>
            <span style="display: block; color: gray; font-size: 0.8em" class="footer-text; text-align:center;"> Saglasno odredbi člana 27. Zakona o zaštiti potrošača, možete popuniti <a href="https://pay.vaulter.rs/Obrazac-za-odustanak-od-ugovora.pdf ">obrazac za odustanak od ugovora</a></span>
        </div>
	</div>[[
}}