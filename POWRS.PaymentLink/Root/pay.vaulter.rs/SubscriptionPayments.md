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
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: lng
JavaScript: js/Events.js
JavaScript: js/XmlHttp.js
JavaScript: js/PaymentLink.js
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

    AgentName := "";
    OrgName := "";   
    OrgTaxNum := ""; 
    OrgAddr := "";
    OrgNr := "";
    OrgActivity:= "";
    OrgActivityNumber:= "";

    if Identity != null then
    (
       AgentName := MarkdownEncode(Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST);
       OrgName  := MarkdownEncode(Identity.ORGNAME);
       OrgTaxNum :=  MarkdownEncode(Identity.ORGTAXNUM);
       OrgAddr :=  MarkdownEncode(Identity.ORGADDR);
       OrgNr := MarkdownEncode(Identity.ORGNR);
       OrgActivity := MarkdownEncode(Identity.ORGACTIVITY);
       OrgActivityNumber:= MarkdownEncode(Identity.ORGACTIVITYNUM);
    );
     
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
    
    RemoteId :=  '';
	IsEcommerce := False;
	SuccessUrl := '';
	ErrorUrl := '';
    foreach Parameter in (Contract.Parameters ?? []) do 
    (
          if Parameter.Name == 'RemoteId' then RemoteId := MarkdownEncode(Parameter.Value);
		  if Parameter.Name == 'IsEcommerce' then IsEcommerce := Bool(Parameter.Value.ToString());
		  if Parameter.Name == 'SuccessUrl' then SuccessUrl := Parameter.Value.ToString();
		  if Parameter.Name == 'ErrorUrl' then ErrorUrl := Parameter.Value.ToString();
    );

    foreach Variable in (CurrentState.VariableValues ?? []) do 
      (        
        Variable.Name like "Title" ?   Title := MarkdownEncode(Variable.Value);
        Variable.Name like "Description" ?   Description := MarkdownEncode(Variable.Value);
        Variable.Name like "Price" ?   ContractValue := MarkdownEncode(Variable.Value.ToString("N2"));
        Variable.Name like "Currency" ?   MarkdownEncode(Currency := Variable.Value);
        Variable.Name like "Country" ?   Country := MarkdownEncode(Variable.Value.ToString());
        Variable.Name like "Commission" ?   Commission := Variable.Value;
        Variable.Name like "Buyer" ?   BuyerFullName := MarkdownEncode(Variable.Value);
        Variable.Name like "BuyerEmail" ?  BuyerEmail := MarkdownEncode(Variable.Value);
        Variable.Name like "EscrowFee" ?   EscrowFee := MarkdownEncode(Variable.Value.ToString("N2"));
        Variable.Name like "AmountToPay" ?   AmountToPay := MarkdownEncode(Variable.Value.ToString("N2"));
        Variable.Name like 'SuccessUrl' ? SuccessUrl := Variable.Value.ToString();
      );

     if(!exists(Country)) then 
     (
        Country := 'RS';
    );
    
    Language:= null;
    if(exists(lng) and lng != "") then
    (
        Language:= Translator.GetLanguageAsync(lng);
      )
      else 
      (
        Language:= Translator.GetLanguageAsync(Country.ToLowerInvariant());
    );

    if(Language == null) then
    (
		Language:= Translator.GetLanguageAsync("rs");
    );
   
    LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
    if(LanguageNamespace == null) then 
    (
		]]<b>Page is not available at the moment</b>[[;
		Return("");
    );
 
    if(ContractState == "AwaitingAuthorization" and Country != Language.Code.ToUpper()) then
      (
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

        Background(SendLangaugeNote(Token.TokenId, Language.Code));
      );

     BuyerFirstName := Before(BuyerFullName," ");
     PayspotId := Before(ID,"@");
     tokenDurationInMinutes:= Int(GetSetting("POWRS.PaymentLink.PayoutPageTokenDuration", 5));
     
     PageToken:= CreateJwt(
            {
                "iss":Gateway.Domain, 
                "contractId": ID,
                "tokenId": Token.TokenId,
                "sub": BuyerFullName, 
                "id": NewGuid().ToString(),
                "ip": Request.RemoteEndPoint,
                "country": Country,
                "ipsOnly": IpsOnly,
                "exp": NowUtc.AddMinutes(tokenDurationInMinutes)
            });
  

			]]<table style="width:100%">
				<tr class="welcomeLbl">   
					<td><img class="vaulterLogo" src="./resources/vaulter_txt.svg" alt="Vaulter"/> </td>
					<td coolspan="2"><select class="select-lng" title="languageDropdown" id="languageDropdown"></select></td>
				</tr>
				<tr>
					<td>**((System.String.Format(LanguageNamespace.GetStringAsync(36).ToString(), BuyerFullName) ))**</td>
					<td style="text-align:right">**ID: ((RemoteId ))**</td>
				</tr>
			</table>
			<div class="payment-details">
			   <table style="width:100%">
				  <tr id="tr_summary">
					 <td class="item border-radius">
						<table style="vertical-align:middle; width:100%;">
						   <tr id="tr_seller_info">
								<td style="width:50%">((LanguageNamespace.GetStringAsync(11) )): ((OrgName ))</td>
								<td style="width:40%"></td>
								<td style="width:10%;text-align:right"><img id="expand_img" class="logo_expand"  src="./resources/expand-down.svg" alt=""  onclick="ExpandSellerDetails()"/></td>
						    </tr>
							<tr id="tr_seller_dtl" style="display:none"  class="agent-info">
								<td>
									<div class="agent-contact-info">
										<p>((OrgAddr ))test</p>
										<p>((MarkdownEncode(CompanyInfo.PhoneNumber) ))</p>
										<p>((MarkdownEncode(CompanyInfo.Email) ))</p>
										<p>((MarkdownEncode(CompanyInfo.WebAddress) ))</p>
									</div>
							    </td>
								<td colspan="2" > 
									<div style="float: right;" align="right" class="agent-detail">
										<p>((LanguageNamespace.GetStringAsync(58) )): ((OrgNr ))</p>
										<p>((LanguageNamespace.GetStringAsync(60) )): (( OrgActivity))</p>
										<p>((LanguageNamespace.GetStringAsync(61) )): (( OrgActivityNumber))</p>
										<p>((LanguageNamespace.GetStringAsync(56) )): (( OrgTaxNum))</p>
									</div>
								</td>
						   </tr>
						</table>
					 </td>
				  </tr>
			   </table>
			   <table style="width:100%">
					<tr id="tr_header" class="table-row">
						<td class="item-header"><strong>((LanguageNamespace.GetStringAsync(39) ))<strong></td>
						<td class="price-header"><strong>((LanguageNamespace.GetStringAsync(40) )) ((LanguageNamespace.GetStringAsync(54) ))<strong></td>
					</tr>
				    <tr id="tr_header_title">
						<td colspan="2" class="item border-radius">
							<table style="vertical-align:middle; width:100%;">
								<tr>
									<td style="width:80%;"> ((Title))</td>
									<td class="itemPrice" rowspan="2">((ContractValue))</td>
									<td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
								</tr>
								<tr>
									<td style="width:70%"> ((Description))</td>
								</tr>
							</table>
						</td>
					</tr>
			   </table>
			</div>
			<div class="spaceItem"></div>[[;
	
	if (ContractState == "AwaitingAuthorization") then 
	(
					]]<div class="vaulter-details">
						<table style="width:100%">
							<tr>
								<td colspan="3">
									<label for="termsAndCondition"><a href="TermsAndCondition.html" target="_blank">**((LanguageNamespace.GetStringAsync(19) ))**</a> vaulter</label>    
								</td>
							</tr>
							<tr >
								<td colspan="3">
									<label for="termsAndConditionAgency"><a onclick="OpenTermsAndConditions(event, this);" urlhref="((CompanyInfo.TermsAndConditions ))">**((LanguageNamespace.GetStringAsync(19) ))**</a> ((OrgName ))</label>
								</td>
							</tr>
						</table>
					</div>[[;
				]]<div class="spaceItem"></div>
				<div class="payment-method-rs"  id="ctn-payment-method-rs">
					<table style="width:100%; text-align:center">[[;
						]]<tr>
							<td>
									<div id="submit-payment">
										<div class="retry-div">
											<button id="payspot-submit" class="retry-btn btn-black btn-show submit-btn" onclick="StartPayment()">((LanguageNamespace.GetStringAsync(73) ))</button> 
										</div>
										<div class="div-payment-notice">
											<label id="payment-notice-lbl" class="lbl-payment-notice">((LanguageNamespace.GetStringAsync(81) )) ((OrgName ))</label>
										</div>
									</div>
							</td>
						</tr>[[;
						]]<tr id="tr_spinner" style="display: none;">
							<td>
								<img src="../resources/spin.svg" alt="loadingSpinner">
							</td>
						</tr>
						<tr>
							<td>
								<iframe id="payspot_iframe" class="payspot_iframe" style="display:none"></iframe>
							</td>
						</tr>
					</table>
				</div>[[;
	)
	else if (ContractState == "AwaitingForPayment") then
	( 
	   ]]<div class="saved-card">
			<div class="card-details-title">
				<div class="saved-card-title">
					<label>Saved Card</label>
				</div>
				<div>
					<button id="add-new-card-btn" class="btn-black btn-show add-new-card-btn">Pay with new card</button>
				</div>
			</div>
			<div class="card-details-div">
				<div class="card-details-row">
					<div class="card-details">
						<div class="card-details-lbl">Card Number:</div>
						<div class="card-value">\*\*\*\* \*\*\*\* \*\*\*\* 1234</div>
					</div>
				</div>
				<div class="card-details_2row">
					<div class="card-details">
						<div class="card-details-lbl">Expiration date:</div>
						<div class="card-value">12/26</div>
					</div>
					<div class="card-details">
						<div class="card-details-lbl">Card Brand:</div>
						<div class="card-value">Visa</div>
					</div>
				</div>
			</div>
		</div>
		<div class="spaceItem"></div>
		<div class="info">
		    <div class="info-payment-date">
				<div>Next payment date</div>
				<div>12/12/2024</div>
			</div>
			<div class="info-payment-action">
				<div class="card-details-lbl">Action</div>
				<div class="info-payment-action-btn">
					<div >
						<button id="add-new-card-btn" class="btn-black btn-show add-new-card-btn">Cancel</button> 
					</div>
				</div>	
			</div>
		</div>[[;
		paymentHistory := Create(System.Collections.Generic.List, System.Object);
		paymentHistory.Add({"01/01/2024",3200.00,true});
		paymentHistory.Add({"01/02/2024",3200.00,true});
		paymentHistory.Add({"01/03/2024",3200.00,true});
		paymentHistory.Add({"01/04/2024",3200.00,true});
		paymentHistory.Add({"01/05/2024",3200.00,false});
		]]<div class="spaceItem"></div>
		<div class="payment-history">
			<div>Payment History</div>
			<div class="payment-table">
				<div class="payment-row">
					<div class="payment-header">Payment Date</div>
					<div class="payment-header">Amount</div>
				</div>[[;
				foreach (payment in paymentHistory) do (
				]]<div class="payment-row">
					<div class="payment-cell">((payment[0] ))</div>
					<div class="payment-cell">((payment[1] ))</div>
				</div>[[;
				);
			]]</div>
		</div>
		<div class="spaceItem"></div>
		<div class="payment-history">[[;
				foreach (payment in paymentHistory) do (
					]]<div class="payment-history-div">
					    <div>
							<div class="payment-history-amount">((payment[1] )) RSD</div>
							<div class="payment-history-date">((payment[0] ))</div>
						</div>
						[[;
						if (payment[2]) then (
							]]<div class="payment-paid">paid</div>[[;
						)else(
						    ]]<div class="payment-failed">failed</div>[[;
						);
						]]
					  </div>
				  <div class="spaceItem"></div>[[;
					);]]
		</div>
		[[;
	)
	else if (ContractState == "PaymentCompleted" || ContractState == "ServiceDelivered" || ContractState == "Done" || ContractState == "ReleaseFundsToSellerFailed" )then 
	(
		]]<div class="payment-completed">**((LanguageNamespace.GetStringAsync(16) ))**</div>
		  <input type="hidden" id="successURL" value='((SuccessUrl ))' /> [[;
    )
	else if ContractState == "PaymentCanceled" then 
	(
		]]**((LanguageNamespace.GetStringAsync(14) ))**
		<input type="hidden" id="cancelURL" value='((ErrorUrl ))' />[[;
	)
	else 
	(
		]]**((LanguageNamespace.GetStringAsync(23) ))**[[;
	);
]]</div>
<input type="hidden" value="((Language.Code ))" id="prefferedLanguage"/>
<input type="hidden" value="((PageToken ))" id="jwt"/>
<input type="hidden" value="POWRS.PaymentLink" id="Namespace"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(10) ))" id="SelectedAccountOk"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(24) ))" id="SelectedAccountNotOk"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(25) ))" id="QrCodeScanMessage"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(26) ))" id="QrCodeScanTitle"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(27) ))" id="TransactionCompleted"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(28) ))" id="TransactionFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(29) ))" id="TransactionInProgress"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(30) ))" id="OpenLinkOnPhoneMessage"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(47) ))" id="SessionTokenExpired"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(74) ))" id="PaymentFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(75) ))" id="PaymentCompletedWaitingRedirection"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(76) ))" id="PaymentFailedWaitingRedirection"/>

<input type="hidden" value="((Request.RemoteEndPoint))" id="currentIp"/>
<input type="hidden" value="((BuyerFullName))" id="buyerFullName"/>
<input type="hidden" value="((BuyerEmail))" id="buyerEmail"/>
<input type="hidden" value="((FileName))" id="fileName"/>
<input type="hidden" value="((Country ))" id="country"/>
<input type="hidden" value="((IsEcommerce ))" id="IsEcommerce"/>
<input type="hidden" value="((ContractState ))" id="ContractState"/>
</main>[[;
}}
<div class="footer-parent">
  <div class="footer">
   Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - 2024 POWRS
  </div>
</div>
</div>