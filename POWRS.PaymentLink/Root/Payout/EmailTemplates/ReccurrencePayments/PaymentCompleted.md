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
Parameter: OrderId

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container" style="width:100%;max-width:600px;margin:0 auto; padding:20px; background-color: #ffffff; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); font-family:arial;">
<div class="content">
{{

Token:=select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId=TokenId;
if (Token == null) then
(
  NotFound("Token not found.");
);

Payment:= select top 1 * from PayspotPayments where OrderId = OrderId and TokenId = TokenId;
if (Payment == null) then 
(
    NotFound("Payment with given order not found");
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
	NotFound("Token not active.");
);


Variables:= CurrentState.VariableValues;
BuyerName:= select top 1 Value from Variables where Name = "Buyer";
BuyerEmail:= select top 1 Value from Variables where Name = "BuyerEmail";
BuyerAddress:= select top 1 Value from Variables where Name = "BuyerAddress";
Title:= select top 1 Value from Variables where Name = "Title";
Description:= select top 1 Value from Variables where Name = "Description";
SellerName:= select top 1 Value from Variables where Name = "SellerName";
Price:= select top 1 Value from Variables where Name = "Price";
AmountToPay:= select top 1 Value from Variables where Name = "AmountToPay";
CancellationReason:= select top 1 Value from Variables where Name = "CancellationReason";
Country:= select top 1 Value from Variables where Name = "Country";
Currency:= select top 1 Value from Variables where Name = "Currency";
RemoteId:= select top 1 Value from Variables where Name = "RemoteId";
localizationCountry:= Country == "RS" ? "sr" : "en";
localization:= Create(POWRS.PaymentLink.Localization.LocalizationService, Create(CultureInfo, localizationCountry), "HtmlTemplates");
year:= Now.Year.ToString();

]]<div class="header" style="text-align: center; padding: 10px;">
      <img src="https://xsjxcz.stripocdn.email/content/guids/CABINET_8b0d8363dad9cf7da11a7b5c5b952fafce23ca1bf4eace9f0d0d772593b69917/images/vaulter_logotype_black_28.png" />
    </div>
    <div class="details" style="margin-top: 20px;">
      <div class="transaction-status">
        <h2 style="color: limegreen; border-bottom: 2px solid; padding-bottom: 5px; margin: 0;">((localization.Get("PaymentCompletedTitle") ))</h2>
        <p style="margin: 0;"><strong>((localization.Get("RemoteIdColumn") )):</strong> ((RemoteId ))</p>
        <p style="margin: 0;"><strong>((localization.Get("PaymentDateColumn") )):</strong> ((Payment.DateCompleted.ToString("dd-MM-yyyy HH:mm") ))</p>
      </div>
      <div class="info" style="margin-top: 10px;">
        <h2 style="color: black; border-bottom: 2px solid black; margin: 0 0 10px 0; padding-bottom: 5px;">((localization.Get("SellerInformationsColumn") ))</h2>
        <p style="margin: 5px 0;"><strong>((localization.Get("NameColumn") )):</strong> ((Identity.ORGNAME ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("OrganizationNumberColumn") )):</strong> ((Identity.ORGNR ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("TaxNumberColumn") )):</strong> ((Identity.ORGTAXNUM ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("AddressColumn") )):</strong> ((Identity.ORGADDR ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("EmailColumn") )):</strong> ((CompanyInfo.Email ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("PhoneNumberColumn") )):</strong> ((CompanyInfo.PhoneNumber ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("WebsiteColumn") )):</strong> ((CompanyInfo.WebAddress )) </p>
      </div>
      <div class="info" style="margin-top: 10px;">
        <h2 style="color: black; border-bottom: 2px solid black; margin: 0 0 10px 0; padding-bottom: 5px;">((localization.Get("BuyerInformationsColumn") ))</h2>
        <p style="margin: 5px 0;"><strong>((localization.Get("NameColumn") )):</strong> ((BuyerName ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("EmailColumn") )):</strong> ((BuyerEmail ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("AddressColumn") )):</strong> ((BuyerAddress ))</p>
      </div>
      <div class="info" style="margin-top: 10px;">
        <h2 style="color: black; border-bottom: 2px solid black; margin: 0 0 10px 0; padding-bottom: 5px;">((localization.Get("TransactionDetailsColumn") ))</h2>
        <p style="margin: 5px 0;"><strong>((localization.Get("ApprovalCodeColumn") )):</strong> ((Payment.AuthNumber ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("PaymentReferenceColumn") )):</strong> ((Payment.BankTransactionId ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("StatusCodeColumn") )):</strong> ((Payment.Result ))</p>
        <p style="margin: 5px 0;"><strong>((localization.Get("StatusColumn") )):</strong> ((localization.Get("CompletedStatus") ))</p>
      </div>
    </div>
    <div class="product" style="margin-top: 20px;">
      <h2 style="color: black; border-bottom: 2px solid black; margin: 0 0 10px 0; padding-bottom: 5px;">((localization.Get("ProductDetailsColumn") ))</h2>
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr>
            <th style="border: 1px solid #dddddd; text-align: left; padding: 8px; background-color: #f2f2f2;">((localization.Get("NameColumn") ))</th>
            <th style="border: 1px solid #dddddd; text-align: left; padding: 8px; background-color: #f2f2f2;">((localization.Get("DescriptionColumn") ))</th>
            <th style="border: 1px solid #dddddd; text-align: left; padding: 8px; background-color: #f2f2f2;">((localization.Get("PriceWithVatColumn") ))</th>
            <th style="border: 1px solid #dddddd; text-align: left; padding: 8px; background-color: #f2f2f2;">((localization.Get("TotalColumn") ))</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">((Title ))</td>
            <td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">((Description ))</td>
            <td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">((Payment.Amount.ToString("f2") )) ((Currency ))</td>
            <td style="border: 1px solid #dddddd; text-align: left; padding: 8px;">((Payment.Amount.ToString("f2") )) ((Currency ))</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="total" style="margin-top: 20px; text-align: right;">
      <p style="margin: 5px 0;"><strong>((localization.Get("TotalColumn") )) ((localization.Get("PriceWithVatColumn") )):</strong> ((AmountToPay )) ((Currency ))</p>
    </div>
    <div class="footer" style="color: #596273; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-style: italic; font-weight: 700; text-align: center;">
      <span class="footer-text" style="display: block; text-align: center;">((localization.Get("FooterCompany") ))</span>
      <span class="footer-text" style="display: block; text-align: center;">((localization.GetFormat("FooterCopyright", year) ))</span>
      <span></span>
      <span class="footer-text" style="display: block; text-align: left; margin-top: 10px;">"((localization.GetFormat("FooterWithdrawalNote", "https://pay.vaulter.rs/Obrazac-za-odustanak-od-ugovora.pdf") ))</span>
    </div>[[;
}}