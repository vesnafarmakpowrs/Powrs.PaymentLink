Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
Pragma: no-cache
Expires: 0
CSS: css/Payout.cssx
CSS: css/Subscription.cssx
CSS: css/IPS.cssx
CSS: css/ProgressBar.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: lng
JavaScript: js/Events.js
JavaScript: js/XmlHttp.js
JavaScript: js/PaymentLink.js
JavaScript: js/Subscription.js
JavaScript: js/PayoutDetails.js

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container">
<div class="content">
{{

try
(
 ID:= Global.DecodeContractId(ID);
)
catch
(
    ]]<b>Payment link is not valid</b>[[;
  Return("");
);

Token:=select top 1 * from IoTBroker.NeuroFeatures.Token where OwnershipContract=ID;
if !exists(Token) then
(
  ]]<b>Payment link is not valid</b>[[;
  Return("");
);

if Token.HasStateMachine then
(
    CurrentState:=Token.GetCurrentStateVariables();
    if exists(CurrentState) then
        ContractState:= CurrentState.State;
);

	VariableValues:= CurrentState.VariableValues;

    Contract:=select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId=ID;
   
    if !exists(Contract) then
    (
     ]]<b>Payment link is not valid</b>[[;
         Return("");
    );

    Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = Contract.Account And State = 'Approved';
    if(Identity == null) then
    (
      ]]<b>Seller is not currently active. Please try again later.</b>[[;
         Return("");
    );

    IpsOnly:= false;
    System.Boolean.TryParse(Identity.IPSONLY, IpsOnly);

    AgentName := MarkdownEncode(Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
    OrgName  := MarkdownEncode(Identity.ORGNAME);
    OrgTaxNum :=  MarkdownEncode(Identity.ORGTAXNUM);
    OrgAddr :=  MarkdownEncode(Identity.ORGADDR);
    OrgNr := MarkdownEncode(Identity.ORGNR);
    OrgActivity := MarkdownEncode(Identity.ORGACTIVITY);
    OrgActivityNumber:= MarkdownEncode(Identity.ORGACTIVITYNUM);
     
    CompanyInfo := select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = Identity.ORGNAME;
    if(CompanyInfo == null) then 
    (
        Return("Not available");
    );
    if(!CompanyInfo.IsValid()) then 
    (
        Return("Not available");
    );

    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;
    SellerId := UpperCase(SellerName.Substring(0,3)); 

    FileName:= SellerId + Token.ShortId;
    
    RemoteId :=  select top 1 Value from CurrentState.VariableValues where Name = "RemoteId";
	SuccessUrl := select top 1 Value from CurrentState.VariableValues where Name = "SuccessUrl";
	ErrorUrl := select top 1 Value from CurrentState.VariableValues where Name = "ErrorUrl";
	Title:= select top 1 Value from CurrentState.VariableValues where Name = "Title";
	Description:= select top 1 Value from CurrentState.VariableValues where Name = "Description";
	Currency:= select top 1 Value from CurrentState.VariableValues where Name = "Currency";
	Language:= select top 1 Value from CurrentState.VariableValues where Name = "Country";
	BuyerFullName:= select top 1 Value from CurrentState.VariableValues where Name = "Buyer";
	BuyerEmail:= select top 1 Value from CurrentState.VariableValues where Name = "BuyerEmail";
	BuyerPhoneNumber:= select top 1 Value from CurrentState.VariableValues where Name = "BuyerPhoneNumber";
	BuyerAddress:= select top 1 Value from CurrentState.VariableValues where Name = "BuyerAddress";
	BuyerCity:= select top 1 Value from CurrentState.VariableValues where Name = "BuyerCity";

	EscrowFee:= select top 1 Value from CurrentState.VariableValues where Name = "EscrowFee";
	AmountToPay:= select top 1 Value from CurrentState.VariableValues where Name = "AmountToPay";
	DeliveryDate:= select top 1 Value from CurrentState.VariableValues where Name = "DeliveryDate";
	TotalNumberOfPayments:= select top 1 Value from CurrentState.VariableValues where Name = "TotalNumberOfPayments";
	TotalCompletedPayments:= select top 1 Value from CurrentState.VariableValues where Name = "TotalCompletedPayments";
	ActiveCardDetails:= select top 1 Value from CurrentState.VariableValues where Name = "ActiveCardDetails";

	TotalPaid:= AmountToPay * TotalCompletedPayments;
	TotalAmountToPay:= AmountToPay * TotalNumberOfPayments;
	if(exists(lng) and lng like '[A-Z]{2}' and lng != Language) then 
	(
			Language:= lng;
		    SendLangaugeNote(tokenId, languageCode):=
		(
			try
				(
					 addNoteEndpoint:= Gateway.GetUrl(":8088/AddNote/" + tokenId);
					 namespace:= "https://" + Gateway.Domain + "/Downloads/EscrowPaylinkRS.xsd";
					Post(addNoteEndpoint ,<LanguageChanged xmlns=namespace language=languageCode.ToUpper() />,{},Waher.IoTGateway.Gateway.Certificate);
				)
				catch
				(
					Log.Error(Exception.Message);
				);
        );

     Background(SendLangaugeNote(Token.TokenId, Language));
	);

	culture:= Language == "RS" ? "sr" : "en";
	localization:= Create(POWRS.PaymentLink.Localization.LocalizationService, Create(CultureInfo, culture), "Payout");

     BuyerFirstName := Before(BuyerFullName," ");
     PayspotId := Before(ID,"@");
     tokenDurationInMinutes:= Int(GetSetting("POWRS.PaymentLink.PayoutPageTokenDuration", 5));
     
	 tabId:= Str(NewGuid());

	if(!exists(Global.PayspotRequests)) then
	(
		Global.PayspotRequests:= Create(Waher.Runtime.Cache.Cache,System.String,System.String,System.Int32.MaxValue,System.TimeSpan.FromHours(0.5),System.TimeSpan.FromHours(0.5));	
	);

	Global.PayspotRequests[ID]:= tabId;

     PageToken:= CreateJwt(
            {
                "iss":Gateway.Domain, 
                "contractId": ID,
                "tokenId": Token.TokenId,
                "sub": BuyerFullName, 
                "id": NewGuid().ToString(),
                "ip": Request.RemoteEndPoint,
				"tabId": tabId,
                "country": Language,
                "ipsOnly": IpsOnly,
                "exp": NowUtc.AddMinutes(tokenDurationInMinutes)
            });
    Payments:= select top 20 * from PayspotPayments where TokenId = Token.TokenId and Result != "" order by DateCreated desc;
		list:= Create(System.Collections.Generic.List, System.Object);
		pendingPayment:= 
		{
			Amount: AmountToPay,
			RefundedAmount: 0,
			DateCreated: DeliveryDate,
			Result: ""
		};
		list.Add(pendingPayment);
		if(Payments != null and Payments.Length > 0) then
			 (
			 	foreach (payment in Payments) do 
				(
					list.Add({
						Amount: payment.Amount,
						RefundedAmount: payment.RefundedAmount,
						DateCreated: payment.DateCreated,
						Result: payment.Result
					});
				);
			);
			pendingAmount := 0;
			pendingDate := "";
			foreach (payment in list) do (
			  if (payment.Result == "") then 
					(
					  pendingAmount := payment.Amount;
					  pendingDate := payment.DateCreated.ToString("MMM dd,yyyy");
					); 
			);

			]]<table style="width:100%">
				<tr class="welcomeLbl">   
					<td><img class="vaulterLogo" src="./resources/vaulter_txt.svg" alt="Vaulter"/> </td>
					<td coolspan="2"><select class="select-lng" title="languageDropdown" id="languageDropdown"></select></td>
				</tr>
				<tr>
					<td>**((localization.GetFormat("HelloUser", BuyerFullName) ))**</td>
					<td style="text-align:right">**ID: ((MarkdownEncode(RemoteId) ))**</td>
				</tr>
			</table>
			<div class="payment-details">
			   <table style="width:100%">
				  <tr id="tr_summary">
					 <td class="item border-radius">
						<table style="vertical-align:middle; width:100%;">
						   <tr id="tr_seller_info">
								<td style="width:50%">((localization.Get("Seller") )): ((OrgName ))</td>
								<td style="width:40%"></td>
								<td style="width:10%;text-align:right"><img id="expand_img" class="logo_expand"  src="./resources/expand-down.svg" alt=""  onclick="ExpandSellerDetails()"/></td>
						    </tr>
							<tr id="tr_seller_dtl" style="display:none"  class="agent-info">
								<td>
									<div class="agent-contact-info">
										<p>((OrgAddr ))</p>
										<p>((MarkdownEncode(CompanyInfo.PhoneNumber) ))</p>
										<p>((MarkdownEncode(CompanyInfo.Email) ))</p>
										<p>((MarkdownEncode(CompanyInfo.WebAddress) ))</p>
									</div>
							    </td>
								<td colspan="2" > 
									<div style="float: right;" align="right" class="agent-detail">
										<p>((localization.Get("RegistrationNumber") )): ((OrgNr ))</p>
										<p>((localization.Get("BusinessActivity") )): (( OrgActivity))</p>
										<p>((localization.Get("ActivityCode") )): (( OrgActivityNumber))</p>
										<p>((localization.Get("TaxID") )): (( OrgTaxNum))</p>
									</div>
								</td>
						   </tr>
						</table>
					 </td>
				  </tr>
			   </table>
			   <table style="width:100%">
					<tr id="tr_header" class="table-row">
						<td class="item-header"><strong>((localization.Get("Product") ))<strong></td>
					</tr>
				    <tr id="tr_header_title">
						<td colspan="2" class="item border-radius">
							<table style="vertical-align:middle; width:100%;">
								<tr>
									<td style="width:80%;"> ((MarkdownEncode(Title) ))</td>
								</tr>
								<tr>
									<td style="width:70%"> ((MarkdownEncode(Description) ))</td>
								</tr>
							</table>
						</td>
					</tr>
			   </table>
			</div>
			<div class="spaceItem"></div>
			<div class="vaulter-details">
						<table style="width:100%">
							<tr>
								<td colspan="3">
									<label for="termsAndCondition"><a href="TermsAndCondition.html" target="_blank">**((localization.Get("TermsOfUse") ))**</a> vaulter</label>    
								</td>
							</tr>
							<tr >
								<td colspan="3">
									<label for="termsAndConditionAgency"><a onclick="OpenTermsAndConditions(event, this);" urlhref="((CompanyInfo.TermsAndConditions ))">**((localization.Get("TermsOfUse") ))**</a> ((OrgName ))</label>
								</td>
							</tr>
						</table>
				</div>
			<div class="spaceItem"></div>
			<div class="saved-card summary" id="PaymentSummary">
				<div class="summary-container">
					<div class="summary-column">
						<div class="summary-row-title">((localization.Get("TotalPaid") ))</div>
						<div class="summary-row-amount">((TotalPaid.ToString("f2") )) ((Currency))</div>
					</div>
					<div class="summary-column">
						<div class="summary-row-title">((localization.Get("TotalRemaining") ))</div>
						<div class="summary-row-amount">(((TotalAmountToPay - TotalPaid).ToString("f2") )) ((Currency))</div>
					</div>
				</div>	 
				<div class="meter green nostripes">
					<span style="width:((((TotalPaid/TotalAmountToPay)* 100).ToString("f2") ))%"></span>
				</div>
				<div class="summary-row-notice">
				  <span>((localization.Get("NextInstallmentOn") ))  ((pendingDate )) : ((pendingAmount )) ((Currency))<span>
				</div>
				<div class="line"></div>
				<div class="summary-container">
					<div class="summary-column summary-total-lbl">((localization.Get("TotalFinanced") ))</div>
					<div class="summary-column">((AmountToPay.ToString("f2") )) ((Currency))</div>
				</div>
			</div>
   		<div class="spaceItem"></div>[[;
	if (ContractState != "PaymentCanceled" and ContractState != "PaymentNotPeformed" and ContractState != "PaymentNotPeformed" and ContractState != "Done") then 
	(
		Log.Informational(ContractState, null);
		]]<div class="saved-card summary" id="billingDetailsForm">
		<div class="width100 vaulter-form">
				<div class="billing-dtl-header-row">
					<div class="billing-dtl-column">
					((localization.Get("BillingDetailsLabel") ))
					</div>
					<div class="billing-dtl-column" style="text-align: right;">
						<button class="btn-black btn-show add-new-card-btn" id="btnEditBuyerDetails" type="button" onclick="EditBuyerDetails();">
							((localization.Get("UpdateLabel") ))
						</button>
					</div>
				</div>
				<div class="billing-dtl-row">
					<div class="billing-dtl-column">
						<input class="width100 billing-dtl-input" type="text" id="fullName" name="fullName" value='((BuyerFullName ))' placeholder="((localization.Get("FullNameLabel") ))" style="display: none;">
						<label id="fullName-lbl">((localization.Get("FullNameLabel") )): ((BuyerFullName ))</label>
					</div>
				</div>
				<div class="billing-dtl-row">
					<div class="billing-dtl-column">
						<input class="width100 billing-dtl-input" type="text" id="address" name="address" value='((BuyerAddress ))' placeholder="((localization.Get("Address") ))" style="display: none;">
						<label id="address-lbl">((localization.Get("Address") )): ((BuyerAddress ))</label>
					</div>
					<div class="billing-dtl-column">
						<input class="width100 billing-dtl-input" type="text" id="city" name="city" value='((BuyerCity ))' placeholder="((localization.Get("CityLabel") ))" style="display: none;">
						<label id="city-lbl">((localization.Get("CityLabel") )): ((BuyerCity ))</label>
					</div>
				</div>
				<div class="billing-dtl-row">
					<div class="billing-dtl-column">
						<input class="width100 billing-dtl-input" type="tel" id="phoneNumber" name="phoneNumber" value='((BuyerPhoneNumber ))' placeholder="((localization.Get("PhoneNumber") ))" style="display: none;">
						<label id="phoneNumber-lbl">((localization.Get("PhoneNumber") )): ((BuyerPhoneNumber ))</label>
					</div>
					<div class="billing-dtl-column">
						<input class="width100 billing-dtl-input" type="email" id="email" name="email" value='((BuyerEmail ))' placeholder="((localization.Get("EmailAddress") ))" style="display: none;">
						<label id="email-lbl">((localization.Get("EmailAddress") )): ((BuyerEmail ))</label>
					</div>
				</div>
			</div>
		</div>
		<div class="spaceItem"></div>
		[[;
		if(exists(ActiveCardDetails.MaskedPan)) then 
		(
			]]<div class="saved-card">
			<div class="card-details-title">
				<div class="saved-card-title">
					<label>((localization.Get("SavedCardLabel") ))</label>
				</div>
				<div>
					<button id="add-new-card-btn" class="btn-black btn-show add-new-card-btn" onclick="InitiateCardAuthorization();">((localization.Get("RegisterNewCard") ))</button>
				</div>
				<div>
					<button class="btn-border-red btn-show add-new-card-btn" onclick="InitiateCancellation();">((localization.Get("Cancel") ))</button>
				</div>
			</div>
			<div class="card-details-div">
				<div class="card-details-row">
					<div class="card-details">
						<div class="card-details-lbl">((localization.Get("CardNumber") ))</div>
						<div class="card-value">((MarkdownEncode(ActiveCardDetails.MaskedPan) ))</div>
					</div>
				</div>
				<div class="card-details_2row">
					<div class="card-details">
						<div class="card-details-lbl">((localization.Get("ExpiryDateLabel") ))</div>
						<div class="card-value">((MarkdownEncode(ActiveCardDetails.ExpiryDate) ))</div>
					</div>
					<div class="card-details">
						<div class="card-details-lbl">((localization.Get("CardBrandLabel") )):</div>
						<div class="card-value">((MarkdownEncode(ActiveCardDetails.CardBrand) ))</div>
					</div>
				</div>
			</div>
		</div>[[;
		)
		else 
		(
			]]<div class="spaceItem"></div>
				<div class="payment-method-rs" id="ctn-payment-method-rs">
					<table style="width:100%; text-align:center">
						<tr>
							<td>
									<div id="submit-payment">
										<div class="retry-div">
											<button id="payspot-submit" class="retry-btn btn-black btn-show submit-btn" onclick="InitiateCardAuthorization();">((localization.Get("RegisterNewCard") ))</button> 
										</div>
										<div class="div-payment-notice">
											<label id="payment-notice-lbl" class="lbl-payment-notice">((localization.Get("AgreeToTermsAgain") )) ((OrgName ))</label>
										</div>
									</div>
							</td>
						</tr>
					</table>
				</div>[[;
		);
		]]<div id="tr_spinner" style="text-align: center; display: none;">
			<img src="../resources/spin.svg" alt="loadingSpinner">
		</div>
		<div>
					<form method="post" id="authorizationForm">
						<input type="hidden" name="PAGE" id="PAGE"/> 
						<input type="hidden" name="AMOUNT" /> 
								<input type="hidden" name="CURRENCY" />
								<input type="hidden" name="LANG" /> 
								<input type="hidden" name="SHOPID" /> 
								<input type="hidden" name="ORDERID" /> 
								<input type="hidden" name="URLDONE" /> 
								<input type="hidden" name="URLBACK" /> 
								<input type="hidden" name="URLMS" /> 
								<input type="hidden" name="ACCOUNTINGMODE" /> 
								<input type="hidden" name="AUTHORMODE" /> 
								<input type="hidden" name="OPTIONS" /> 
								<input type="hidden" name="EMAIL" /> 
								<input type="hidden" name="TRECURR" /> 
								<input type="hidden" name="EXPONENT" /> 
								<input type="hidden" name="MAC" />
								</form>
		</div>[[;
	)
	else if (ContractState == "Done")then 
	(
		]]<div class="payment-completed">**((localization.Get("PaymentSuccessful") ))**</div>
		  <input type="hidden" id="successURL" value='((SuccessUrl ))' /> [[;
    )
	else if (ContractState == "PaymentCanceled" or ContractState == "PaymentNotPeformed") then 
	(
		]]<b style="color:red;">((localization.Get("Cancelled") ))</b>
		<input type="hidden" id="cancelURL" value='((ErrorUrl ))' />[[;
	)
	else 
	(
		]]**((localization.Get("PaymentLinkExpiredAgain") ))**[[;
	);
		]]
		<div class="spaceItem"></div>
		[[;
		
		

		]]<div class="spaceItem"></div>
		<div class="payment-history">
			<div>((localization.Get("PaymentHistoryLabel") ))</div>
			 <div class="spaceItem"></div>[[;
			 	foreach (payment in list) do (
					]]
					<div class="payment-container">
					  <div class="payment-history-div">
					    <div>
							<div class="payment-history-amount">((payment.Amount.ToString("f2") )) ((Currency ))</div>
							<div class="payment-history-date">((payment.DateCreated.ToString("MMM dd, yyyy") ))</div>	[[;
						]]</div></div>[[;
						if(payment.RefundedAmount != null and payment.RefundedAmount > 0) then 
						(
							]]<div class="payment-sticker refunded">((localization.Get("RefundedLabel") ))</div>[[;
						)
						else if (payment.Result == '00') then 
						(
							]]<div class="payment-sticker paid">((localization.Get("PaidLabel") ))</div>[[;
						)
						else if (payment.Result != "" and payment.Result != "00") then 
						(
						    ]]<div class="payment-sticker failed">((localization.Get("FailedLabel") ))</div>[[;
						)
						else 
						(
						   ]]<div class="payment-sticker pending">((localization.Get("PendingLabel") ))</div>[[;
						);
						]]</div>					   
				     <div class="payment-history-space"></div>[[;
					);
			]]</div>
		 <div class="spaceItem"></div>
		 <div class="spaceItem"></div>
		 <div class="spaceItem"></div>
		 <div class="spaceItem"></div>
		</div>
		</div>
		</div>
</div>
<input type="hidden" value="((Language ))" id="prefferedLanguage"/>
<input type="hidden" value="((PageToken ))" id="jwt"/>
<input type="hidden" value="POWRS.PaymentLink" id="Namespace"/>
<input type="hidden" value="((localization.Get("ScanIPSQRCode") ))" id="QrCodeScanMessage"/>
<input type="hidden" value="((localization.Get("BankIDAuthorization") ))" id="QrCodeScanTitle"/>
<input type="hidden" value="((localization.Get("PaymentSuccessfulThankYou") ))" id="TransactionCompleted"/>
<input type="hidden" value="((localization.Get("PaymentNotPossible") ))" id="TransactionFailed"/>
<input type="hidden" value="((localization.Get("PaymentInProgress") ))" id="TransactionInProgress"/>
<input type="hidden" value="((localization.Get("OpenPaymentLinkOnPhone") ))" id="OpenLinkOnPhoneMessage"/>
<input type="hidden" value="((localization.Get("SessionExpired") ))" id="SessionTokenExpired"/>
<input type="hidden" value="((localization.Get("PaymentUnsuccessful") ))" id="PaymentFailed"/>
<input type="hidden" value="((localization.Get("PaymentSuccessfulRedirect") ))" id="PaymentCompletedWaitingRedirection"/>
<input type="hidden" value="((localization.Get("PaymentUnsuccessfulRedirect") ))" id="PaymentFailedWaitingRedirection"/>

<input type="hidden" value="((Request.RemoteEndPoint))" id="currentIp"/>
<input type="hidden" value="((tabId))" id="pageTabId"/>
<input type="hidden" value="((BuyerFullName))" id="buyerFullName"/>
<input type="hidden" value="((BuyerEmail))" id="buyerEmail"/>
<input type="hidden" value="((FileName))" id="fileName"/>
<input type="hidden" value="((Language ))" id="country"/>
<input type="hidden" value="((ContractState ))" id="ContractState"/>
</main>
<div class="footer-parent">
  <div class="footer">
  ((localization.Get("FooterCompanyInfo1") ))
  </br>
   ((localization.GetFormat("FooterCompanyInfo2", Str(Now.Year) ) ))
  </div>
</div>
</div>[[;
}}