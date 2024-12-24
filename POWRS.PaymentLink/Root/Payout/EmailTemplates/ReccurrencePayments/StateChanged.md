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

WriteCancelationReason():= 
(
	CancellationReason:= select top 1 Value from Variables where Name = "CancellationReason";
	if(CancellationReason == 'Buyer') then
			(
				]]<div class="try-again">
					<p><strong>((localization.GetFormat("CancellationBuyerMessage",BuyerName) )) </strong></p>
				<div>[[;
			)
			else if(CancellationReason == 'Seller') then 
			(
				]]<div class="try-again">
					<p><strong>((localization.GetFormat("CancellationSellerMessage",SellerName) ))</strong></p>
				<div>[[;
			)
			else if(FailedPaymentAttempts >= MaxFailedPaymentAttempts) then 
			(
				]]<div class="try-again">
					<p><strong>((localization.GetFormat("MaxPaymentAttemptsExceeded",MaxFailedPaymentAttempts) ))</strong></p>
				<div>[[;
			);
			else
			(
				]]<div class="try-again">
					<p><strong>((localization.Get("CancellationDeadlineMessage") ))</strong></p>
				<div>[[;
			);
);

Variables:= CurrentState.VariableValues;
State:= CurrentState.State;
BuyerName:= select top 1 Value from Variables where Name = "Buyer";
SellerName:= select top 1 Value from Variables where Name = "SellerName";
Title:= select top 1 Value from Variables where Name = "Title";
RemoteId:= select top 1 Value from Variables where Name = "RemoteId";
Description:= select top 1 Value from Variables where Name = "Description";
Country:= select top 1 Value from Variables where Name = "Country";
CardRegistrationAmount:= select top 1 Value from Variables where Name = "CardRegistrationAmount";
MaxFailedPaymentAttempts:= select top 1 Value from Variables where Name = "MaxFailedPaymentAttempts";
FailedPaymentAttempts:= select top 1 Value from Variables where Name = "FailedPaymentAttempts";
TotalNumberOfPayments:= select top 1 Value from Variables where Name = "TotalNumberOfPayments";
Price:= select top 1 Value from Variables where Name = "Price";
Currency:= select top 1 Value from Variables where Name = "Currency";
DeliveryDate:= select top 1 Value from Variables where Name = "Currency";
TotalToPay:= (TotalNumberOfPayments * Price).ToString("f2");
localizationCountry:= Country == "RS" ? "sr" : "en";
localization:= Create(POWRS.PaymentLink.Localization.LocalizationService, Create(CultureInfo, localizationCountry), "HtmlTemplates");
year:= Now.Year.ToString();
Payments:= select * from PayspotPayments where TokenId = TokenId;

	 	]]<div class="header" style="text-align: center; padding: 10px;">
            <img src="https://xsjxcz.stripocdn.email/content/guids/CABINET_8b0d8363dad9cf7da11a7b5c5b952fafce23ca1bf4eace9f0d0d772593b69917/images/vaulter_logotype_black_28.png" />
        </div>
        <div class="details">
            <div class="transaction-status">
				<div id="status" style="color:	#ffcc00; border-bottom:	#ffcc00 2px solid; padding-bottom:0;">
					 <h2 style="margin: 0.5em 0em;">((localization.Get("StateChanged") ))</h2>
				</div>
				<div id="description">
					<p>((localization.GetFormat("StateChangedDescription",BuyerName) ))</p>
				</div>
				<div>
				<table style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; border: 1px solid #ddd;">
					<caption style="font-size: 16px; font-weight: bold; margin-bottom: 10px;">((localization.Get("ProductDetailsColumn") ))</caption>
					<thead>
						<tr>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("NameColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("RemoteIdColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("DescriptionColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("TotalPaymentsColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("PriceWithVatColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("TotalColumn") ))</th>
						</tr>
					</thead>
					<tbody><tr>
							<td style="padding: 8px; border: 1px solid #ddd;">((Title ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((RemoteId ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((Description ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((TotalNumberOfPayments))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((Price))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((TotalToPay )) ((Currency ))</td>							
						</tr>
						</tbody>
					</table>
				</div>
			</div>[[;
			if(State == "AwaitingCardRegistration") then 
			(
			]]<p>((localization.GetFormat("StateChangedAwaitingCardRegistrationDescription", BuyerName, Title) ))</p>[[;		
			)
			else if(State == "PaymentNotPeformed") then 
			(
				WriteCancelationReason();
			)
			else if(State == "CardRegistrationCompleted") then
			(
				]]<p>((localization.Get("CardRegistrationCompleted") ))</p>[[;
			)
			else if(State == "PaymentCompleted") then 
			(
				WriteCancelationReason();
			)
			else if(State == "PaymentFailed") then 
			(
				]]<p>((localization.Get("PaymentFailed") ))</p>[[;
				if(FailedPaymentAttempts < MaxFailedPaymentAttempts) then 
				(
					]]<p>((localization.GetFormat("PaymentFailedNextRetryMessage", DeliveryDate.ToString("dd-MM-YYYY")) ))</p>[[;
				);
			)
			else if(State == "PaymentCanceled") then 
			(
				WriteCancelationReason();
			)
			else if(State == "Done") then 
			(
				]]<p>((localization.GetFormat("PaymentCompletedMessage",SellerName, Title, BuyerName) ))</p>[[;
			);
			if(Payments != null and Payments.Length > 0) then 
			(
				]]<div style="margin-bottom:20px;">
					<table style="width: 100%; border-collapse: collapse; font-size: 14px; text-align: left; border: 1px solid #ddd;">
					<caption style="font-size: 16px; font-weight: bold; margin-bottom: 10px;">((localization.Get("AllTransactionsCaption") ))</caption>
					<thead>
						<tr>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("MaskedPanColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("BrandColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("AmountColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("AuthColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("CodeColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;">((localization.Get("DateColumn") ))</th>
							<th style="padding: 8px; border: 1px solid #ddd; background-color: #f4f4f4;"></th>
						</tr>
					</thead>
					<tbody>[[;
						foreach(item in Payments) do 
						(
							color:= item.RefundedAmount > 0 ? "orange" : (item.Result == "00" ? "green" : "red");
						]]<tr>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.MaskedPan ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.CardBrand ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.Amount )) ((Currency ))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.AuthNumber))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.Result))</td>
							<td style="padding: 8px; border: 1px solid #ddd;">((item.DateCompleted.ToString("dd-MM-yyyy") ))</td>
							<td style="padding: 8px; border: 1px solid #ddd; color: ((color ))">((item.RefundedAmount > 0 ? localization.Get("RefundedStatus") : (item.Result == "00" ?  localization.Get("CompletedStatus") : localization.Get("FailedStatus")) ))</td>
						</tr>[[;
						);
						]]</tbody>
					</table>
				</div>[[;
			);
        ]]</div>
		<div style="text-align: center;">
		<i><p style="color: gray;  font-size: 0.8em">((localization.Get("ThankYouMessage") ))</p></i>
		</div>
		 <div class="footer"style="text-align: center;">
            <span class="footer-text" style="display: block;color: gray; font-size: 0.8em; text-align:center;">((localization.Get("FooterCompany") ))</span>
            <span class="footer-text" style="display: block;color: gray; font-size: 0.8em; text-align:center;">((localization.GetFormat("FooterCopyright", year) ))</span>
        </div>
	</div>[[
}}