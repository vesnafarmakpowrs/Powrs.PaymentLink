﻿Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
Pragma: no-cache
Expires: 0
CSS: css/Payout.cssx
CSS: css/IPS.cssx
CSS: css/Info.cssx
CSS: css/BankList.css
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: TYPE
Parameter: lng
JavaScript: js/Events.js
JavaScript: js/XmlHttp.js
JavaScript: js/PayoutDetails.js
JavaScript: js/PaymentLinkIPS.js
JavaScript: js/QRIPS.js
JavaScript: js/IPSMobile.js


<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container">
<div class="content">
{{
  Language:= null;
if(exists(lng)) then 
(
  Language:= Translator.GetLanguageAsync(lng);
);
if(Language == null) then 
(
 lng:= "rs";
 Language:= Translator.GetLanguageAsync("rs");
);

LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
if(LanguageNamespace == null) then 
(
 ]]<b>Page is not available at the moment</b>[[;
 Return("");
);


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

	PaymentResult := select Top 1 Result from PayspotPayments where TokenId = Token.TokenId;

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
		Variable.Name like 'SuccessUrl' ? SuccessUrl := Variable.Value;
	);

	Country := 'RS';
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
			"language": lng,
			"exp": NowUtc.AddMinutes(tokenDurationInMinutes)
		});
	bankList := Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Models.GetBanks.Bank);
	
		if (TYPE != "" && ContractState == "AwaitingForPayment") then
		(
		    if ( TYPE == 'IE') then 
			(
				bankList := POWRS.Payment.PaySpot.PayspotService.GetIndividualBankList();
			)
			else if (TYPE == 'LE') then
			(
				bankList := POWRS.Payment.PaySpot.PayspotService.GetLegalBankList();
			);
			 ]]<div class="dropdown" id="select-bank"> 
				<label class="select-bank-lbl">((LanguageNamespace.GetStringAsync(82) ))</label>
					<ul id="bankList" class="bank-list-ul"> [[;
						foreach bank in bankList do 
					   ( 
							bankName:= bank.Name;
							imageName :=  Before(bank.Name," ") != null ? Before(bank.Name," ") : bank.Name;
							Contains(bank.Name,"INTESA") ? imageName := "intesa";
							Contains(bank.Name,"POŠTANSKA") ? imageName := "pbs";
							bankName := TrimEnd(bankName);
							bankName := TrimStart(bankName);
							imgSrc := "..\\resources\\personal_round\\"+ imageName + ".jpg";
							if (bank.ID != 5) then
							  ]]<li class="dropdown-item" onClick="OpenDeepLink( ((bank.ID )) )"> <img src="(( imgSrc))" class="bank-img" /><label>((bankName ))</label></li> [[;
						);     
					]]</ul>            
				</div>[[
		)
		else  
	    (
			if (!IsEcommerce ) then
			 (
				]]  <table style="width:100%">
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
					<div class="spaceItem"></div>
					[[;
				);	
			);
				
			if (ContractState == "AwaitingForPayment" and TYPE=="") then 
			( 
			   
				if (!IsEcommerce ) then
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
				);
				]]<div class="spaceItem"></div>
				<div id="retry-payment" style="display:none">
				   <div class="retry-div" >
					<button id="payspot-submit" class="retry-btn btn-black btn-show" onclick="RetryPayment()">((LanguageNamespace.GetStringAsync(78) ))</button> 
				  </div>
				</div>
				<div id="submit-payment" >
				   <div class="retry-div" >
					<button id="payspot-submit" class="retry-btn btn-black btn-show submit-btn" onclick="LoadIPS(0)">((LanguageNamespace.GetStringAsync(73) ))</button> 
				  </div>
				  <div class="div-payment-notice">
					<label id="payment-notice-lbl" class="lbl-payment-notice">((LanguageNamespace.GetStringAsync(79) )) ((OrgName )).</label>
				  </div>
				</div>
				<div id="payment-msg-div"  style="display:none">
				   <div id="payment-msg" class="retry-div" ></div>
				</div>
				<div id="ips-method" style="display:none">
					<div >
						<div class="div-logo-ips-mob">
							<img src="./resources/ipslogo.png" alt="ipsLogoScan"/>
						</div>  
						<div class="pay-div pay-div-header" >
							<label>((LanguageNamespace.GetStringAsync(67) ))</label>
							<img src="resources\info.png" class="img-info" onclick="infoPopup()"/> 
						</div>
						<div class="pay-div" ><button class="pay-btn btn-black" onclick="getbanksIE()">((LanguageNamespace.GetStringAsync(63) ))</button> </div>
						<div class="pay-div" ><button class="pay-btn btn-grey" onclick="getbanksLE()">((LanguageNamespace.GetStringAsync(64) ))</button></div>
					</div>
					<div id="popupOverlay" class="overlay-container"> 
					<div class="popup-box"> 
						<h2 style="color: green;"></h2> 
						<form class="form-container"> 
							<label class="form-label">((LanguageNamespace.GetStringAsync(65) ))</label> 
						</form> 
						<button class="btn-close-popup pay-btn btn-black" onclick="infoPopup()">((LanguageNamespace.GetStringAsync(66) ))</button> 
					</div> 
					</div> 
				</div>
				 <div id="IPSScan" style="display:none"> 
					   <div class="article">
							<div class="div-logo-ips">
								<img src="./resources/ipslogo.png" alt="ipsLogoScan"/>
								<img src="./resources/vaulter_logo.webp" alt="VaulterLogo"/>
							</div>    
							<div><label>((LanguageNamespace.GetStringAsync(68) ))</label> </div>
					   </div> 
					   <div class="div-ips-code">
						  <div> 
							  <img id="QRCode" style="filter: blur(3px)" src="data:image/jpg;base64, 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" alt="">
						  </div>
						  <div class="qr-timer">
							  <strong><div class="pomView" timer id="timer"></div></strong>
						  </div>   
						  <div class="gen-wrap">
							  <div id="msg-time-expire" class="msg">((LanguageNamespace.GetStringAsync(69) ))</div>
							  <div id="msg-generate-qrcode" class="msg">((LanguageNamespace.GetStringAsync(70) ))</div>
							  <div class="pay-div" display="none"><button id="btnGenerateQR" class="pay-btn btn-black btn-hide" onclick="getQRCode()">((LanguageNamespace.GetStringAsync(71) ))</button> </div>
							  <div class="cancel-div"> <button  id="btnCancelQR"  onclick="cancelTransaction()"  type="button" class="pay-btn btn-grey" id="cancel_btn">((LanguageNamespace.GetStringAsync(72) ))</button></div>
						  </div> 
					  </div>
					</div>  
				[[;
			)
			else if (ContractState == "PaymentCompleted" || ContractState == "ServiceDelivered" || ContractState == "Done" )then 
			(
			]]<div class="payment-completed"><p>**((LanguageNamespace.GetStringAsync(16) ))**</p> [[;

			   DateCompleted := select top 1 Value from CurrentState.VariableValues where Name = "PaymentDateTimeInBuyerLocalTime";
			   if(DateCompleted != null) then
			   (
			]]<p>**Datum plaćanja: ((DateCompleted.ToString("dd-MM-yyyy HH:mm") ))**</p></div>
			  <input type="hidden" id="successURL" value='((SuccessUrl ))' /> [[;
			   )
			   else 
			   (
				DateCompleted := select top 1 Value from CurrentState.VariableValues where Name = "PaymentDateTime";
				]]<p>**Datum plaćanja: ((DateCompleted.ToLocalTime().ToString("dd-MM-yyyy HH:mm") ))**</p></div>
			  <input type="hidden" id="successURL" value='((SuccessUrl ))' /> [[;
			   );
			)
			else if ContractState == "PaymentCanceled" then 
			(
			  ]]**((LanguageNamespace.GetStringAsync(80) ))**
			   <input type="hidden" id="cancelURL" value='((ErrorUrl ))' />[[;
			)
			else if (TYPE == "") then
			(
			  ]]**((LanguageNamespace.GetStringAsync(23) ))**[[;
			);
		
]]</div>
   <input type="hidden" value="((lng ))" id="prefferedLanguage"/>
	<input type="hidden" value="((PageToken ))" id="jwt"/>
	<input type="hidden" value="((TYPE ))" id="type"/>
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
	<input type="hidden" value="true" id="IpsOnly"/>
	<input type="hidden" value="((Request.RemoteEndPoint))" id="currentIp"/>
	<input type="hidden" value="((BuyerFullName))" id="buyerFullName"/>
	<input type="hidden" value="((BuyerEmail))" id="buyerEmail"/>
	<input type="hidden" value="((FileName))" id="fileName"/>
	<input type="hidden" value="((Country ))" id="country"/>
	<input type="hidden" value="((IsEcommerce ))" id="IsEcommerce"/>
	<input type="hidden" value="((PaymentResult ))" id="PaymentResult"/>
</main>[[;
}}
<div class="footer-parent">
  <div class="footer">
		<div class="ips-footer">
			 <div class="div-logo-ips-footer">
				<img src="data:image/png;base64,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">
			 </div>
			 <div>Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2,<br/> Beograd Serbia ©2021 - 2024 POWRS<div>
		</div>
   </div>
</div>
</div>