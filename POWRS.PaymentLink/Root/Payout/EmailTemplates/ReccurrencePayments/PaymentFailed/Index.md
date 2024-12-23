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
BuyerAddress:= select top 1 Value from Variables where Name = "BuyerAddress";
BuyerCity:= select top 1 Value from Variables where Name = "BuyerCity";
BuyerEmail:= select top 1 Value from Variables where Name = "BuyerEmail";
BuyerPhoneNumber:= select top 1 Value from Variables where Name = "BuyerPhoneNumber";
Title:= select top 1 Value from Variables where Name = "Title";
SellerName:= select top 1 Value from Variables where Name = "SellerName";
CancellationReason:= select top 1 Value from Variables where Name = "CancellationReason";
Country:= select top 1 Value from Variables where Name = "Country";
MaxFailedAttempts:= select top 1 Value from Variables where Name = "MaxFailedPaymentAttempts";
FailedPaymentAttempts:= select top 1 Value from Variables where Name = "FailedPaymentAttempts";
ActiveCardDetails:= select top 1 Value from Variables where Name = "ActiveCardDetails";
Amount:= select top 1 Value from Variables where Name = "AmountToPay";
Link:= select top 1 Value from Variables where Name = "Link";
localizationCountry:= Country == "RS" ? "sr" : "en";
localization:= Create(POWRS.PaymentLink.Localization.LocalizationService, Create(CultureInfo, localizationCountry), "HtmlTemplates");
year:= Now.Year.ToString();

	 	]]<div class="header" style="text-align: center; padding: 10px;">
            <img src="https://xsjxcz.stripocdn.email/content/guids/CABINET_8b0d8363dad9cf7da11a7b5c5b952fafce23ca1bf4eace9f0d0d772593b69917/images/vaulter_logotype_black_28.png" />
        </div>
        <div class="details">
            <div class="transaction-status">
				<div id="status" style="color:red; border-bottom:red 2px solid; padding-bottom:0;">
					 <h2 style="margin: 0.5em 0em;">((localization.Get("PaymentFailedTitle") ))</h2>
				</div>
				<div id="description">
					<p>((localization.GetFormat("PaymentFailedMessage", BuyerName, Title) ))</p>
					<p>((localization.Get("RetryMessage") ))</p>
					<span style="display: block;">((localization.GetFormat("MaxAttemptsNote", Str(MaxFailedAttempts)) ))</span>
					<span style="display: block;">((localization.GetFormat("CurrentAttempt", Str(FailedPaymentAttempts)) ))</span>
					<p>Once this this number exceeds, your product will automatically be cancelled, and in order to renew, you will have to contact seller directly.</p>
				</div>
				<div style="margin-bottom:20px;">
					<table style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; border: 1px solid #ddd;">
					<caption style="font-size: 16px; font-weight: bold; margin-bottom: 10px;">((localization.Get("BuyerDetailsCaption") ))</caption>
					<thead>
						<tr>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("NameColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("AddressColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("CityColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("PhoneNumberColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("EmailColumn") ))</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td style="padding: 8px; border: 1px solid #ddd;">((BuyerName ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((BuyerAddress ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((BuyerCity ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((BuyerPhoneNumber))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((BuyerEmail))</td>
						</tr>
						</tbody>
					</table>
				</div>
				<div>
					<table style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; border: 1px solid #ddd;">
					<caption style="font-size: 16px; font-weight: bold; margin-bottom: 10px;">((localization.Get("CardDetailsCaption") ))</caption>
					<thead>
						<tr>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("MaskedPanColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("ExpirationDateColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("BrandColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("AmountColumn") ))</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td style="padding: 8px; border: 1px solid #ddd;">((ActiveCardDetails.MaskedPan ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((ActiveCardDetails.ExpiryDate ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((ActiveCardDetails.CardBrand ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((Amount.ToString("f2") )) ((Currency ))</td>
						</tr>
						</tbody>
					</table>
				</div>
				<div>
					<p>((localization.GetFormat("CheckDetailsMessage", Link) ))</p>
				</div>
			</div>
		</div>
		<div>
		<p>((localization.GetFormat("ContactSellerMessage",CompanyInfo.PhoneNumber, CompanyInfo.Email) ))</p>
		</div>		
		 <div class="footer"style="text-align: center;">
            <span class="footer-text" style="display: block;color: gray; font-size: 0.8em; text-align:center;">((localization.Get("FooterCompany") ))</span>
            <span class="footer-text" style="display: block;color: gray; font-size: 0.8em; text-align:center;"((localization.GetFormat("FooterCopyright", year) ))</span>
            <span style="display: block; color: gray; font-size: 0.8em" class="footer-text; text-align:center;">((localization.GetFormat("FooterWithdrawalNote", "https://pay.vaulter.rs/Obrazac-za-odustanak-od-ugovora.pdf") )) </span>
        </div>
	</div>[[
}}