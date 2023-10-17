Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/Payout.cssx
Parameter: ID
Parameter: lng
JavaScript: js/Events.js
JavaScript: js/PaymentLink.js
JavaScript: https://js.stripe.com/v3/

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="content">
<b><h2></h2></b>
{{

 Language:= null;
if(exists(lng)) then 
(
  Language:= Translator.GetLanguageAsync(lng);
);
if(Language == null) then 
(
 lng:= "sv";
 Language:= Translator.GetLanguageAsync("sv");
);

LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
if(LanguageNamespace == null) then 
(
 BadRequest("Page is not available at the moment");
);

ID += "@legal." + Gateway.Domain; 

Token:=select top 1 * from IoTBroker.NeuroFeatures.Token where OwnershipContract=ID;

if !exists(Token) then 
	NotFound("Item does not found.");

if Token.HasStateMachine then
(
	CurrentState:=Token.GetCurrentStateVariables();
	if exists(CurrentState) then
		ContractState:= CurrentState.State;
);
if ContractState == "AwaitingForPayment" then 
(
    Contract:=select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId=ID;
   
    if !exists(Contract) then
    (
	NotFound("Contract not found.");
    )
    else
    (
	    v:=Create(Waher.Script.Variables,[]);
	    foreach Parameter in Contract.Parameters do Parameter.Populate(v);
	    foreach Parameter in Contract.Parameters do Parameter.IsParameterValid(v);
    );

    Identities:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = Contract.Account And State = 'Approved';

    AgentName := "";
    OrgName := "";
    foreach I in Identities do
    (
       AgentName := I.FIRST + " " + I.MIDDLE + " " + I.LAST;
       OrgName  := I.ORGNAME;
    );

    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;
    SellerId := UpperCase(SellerName.Substring(0,3)); 

    FileName:= SellerId + Token.ShortId;


    foreach Parameter in (Contract.Parameters ?? []) do 
      (
        Parameter.Name like "Title" ?   Title := Parameter.MarkdownValue;
        Parameter.Name like "Description" ?   Description := Parameter.MarkdownValue;
        Parameter.Name like "Value" ?   Value := Parameter.ObjectValue.ToString("N2");
        Parameter.Name like "Currency" ?   Currency := Parameter.MarkdownValue;
        Parameter.Name like "Commission" ?   Commission := Parameter.MarkdownValue;
        Parameter.Name like "BuyerFullName" ?   BuyerFullName := Parameter.MarkdownValue;
        Parameter.Name like "BuyerEmail" ?  BuyerEmail := Parameter.MarkdownValue;
        Parameter.Name like "BuyerPersonalNum" ?   BuyerPersonalNum := Parameter.MarkdownValue;
        Parameter.Name like "EscrowFee" ?   EscrowFee := Parameter.ObjectValue.ToString("N2");
        Parameter.Name like "AmountToPay" ?   AmountToPay := Parameter.ObjectValue.ToString("N2");
      );
BuyerFirstName := Before(BuyerFullName," ");
]]

<table style="width:100%">
  <tr class="welcomeLbl">   
    <td rowspan="2"><img class="vaulterLogo" src="./resources/vaulterlogo.svg" alt="Vaulter"/> </td>
    <td>**((LanguageNamespace.GetStringAsync(22) )), ((BuyerFirstName))** </td>
    <td rowspan="2"><select title="languageDropdown" id="languageDropdown"></select></td>
  </tr>
  <tr>
    <td>
       ((LanguageNamespace.GetStringAsync(6) ))
    </td>
  </tr>
</table>

<input type="hidden" value="((lng ))" id="prefferedLanguage"/>
<input type="hidden" value="POWRS.PaymentLink" id="Namespace"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(10) ))" id="SelectedAccountOk"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(24) ))" id="SelectedAccountNotOk"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(25) ))" id="QrCodeScanMessage"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(26) ))" id="QrCodeScanTitle"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(27) ))" id="TransactionCompleted"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(28) ))" id="TransactionFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(29) ))" id="TransactionInProgress"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(30) ))" id="OpenLinkOnPhoneMessage"/>

<input type="hidden" value="((Token.TokenId))" id="TokenId"/>
<input type="hidden" value="((Contract.ContractId))" id="contractId"/>
<input type="hidden" value="((BuyerPersonalNum))" id="personalNumber"/>
<input type="hidden" value="((BuyerFullName))" id="buyerFullName"/>
<input type="hidden" value="((BuyerEmail))" id="buyerEmail"/>
<input type="hidden" value="((FileName))" id="fileName"/>

<div class="payer-details">
<table>
 <tr>
  <td coolspan="2">
    **((LanguageNamespace.GetStringAsync(31) ))**
  </td>
 </tr>
<tr>
  <td class="payerName">
    ((LanguageNamespace.GetStringAsync(4) )):
  </td>
  <td class="payerValue">
  **((MarkdownEncode(BuyerFullName) ))**
  </td>
 </tr>
<tr>
  <td class="payerName">
    ((LanguageNamespace.GetStringAsync(3) )):
  </td>
  <td class="payerValue">
   **((BuyerEmail ))**
  </td>
 </tr>
</table>
</div>


<br/>

<div class="payment-details">
<table style="width:100%">
 <tr>
  <td colspan="2">
    **((LanguageNamespace.GetStringAsync(32) ))**
  </td>
 </tr>
<tr>
  <td class="payerName">
    ((LanguageNamespace.GetStringAsync(11) )):
  </td>
  <td class="payerValue">
  **((SellerName))****
  </td>
 </tr>

 <tr class="spaceUnder"><td colspan="2"> </td></tr>
<tr>
  <td colspan="2" class="item border-radius" >
      <table style="vertical-align:middle; width:100%;">
         <tr>
            <td style="width:80%;"> ((Title))</td>
            <td class="itemPrice"  rowspan="2" >((Value ))<td>
            <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
         </tr>
         <tr>
            <td style="width:70%"> ((Description))</td>
         </tr>
      </table>
  </td>
 </tr>

 <tr class="spaceUnder"><td colspan="2"> </td></tr>
<tr class="spaceUnder">
  <td colspan="2" class="item border-radius">
      <table style="vertical-align:middle; width:100%;">
         <tr>
           <td style="width:80%">((LanguageNamespace.GetStringAsync(21) ))</td>
           <td class="itemPrice"  rowspan="2" >((EscrowFee))<td>
           <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
         </tr>
      </table>
  </td>
 </tr>

 <tr class="spaceUnder"><td colspan="2"> </td></tr>
<tr>
  <td colspan="2" class="item border-radius">
      <table style="vertical-align:middle; width:100%;">
         <tr>
           <td style="width:80%">**((LanguageNamespace.GetStringAsync(20) ))**</td>
           <td class="itemPrice"  rowspan="2" >((AmountToPay))<td>
           <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
         </tr>
      </table>
  </td>
 </tr>
</table>
</div>
  
<div class="spaceItem"></div>
<br/>

<div class="vaulter-details">
<table style="width:100%">
 <tr>
  <td colspan="3"><img class="vaulter_Logo" src="./resources/vaulter_logo.svg" alt="Vaulter"/> </td>
 </tr>
 <tr >
  <td colspan="3">
     <input type="checkbox" id="termsAndCondition" name="termsAndCondition" onclick="UserAgree();">
     <label for="termsAndCondition"><a href="https://www.powrs.se/terms-and-conditions-payment-link" target="_blank">**((LanguageNamespace.GetStringAsync(19) ))**</a></label> 
   </td>
 </tr>
 <tr class="spaceUnder">
    <td colspan="3">
      <input type="checkbox" id="purchaseAgreement" name="purchaseAgreement" onclick="UserAgree();">
      <label for="purchaseAgreement"><a href="#" onclick="generatePDF();event.preventDefault();" >**((LanguageNamespace.GetStringAsync(7) ))**</a></label> 
   </td>
 </tr>
 <tr class="spaceUnder"><td colspan="3"> </td></tr>
  <tr class="safeguarded" >
     <td style="width:80%; text-align:left">((LanguageNamespace.GetStringAsync(1) ))</td>
     <td class="moneyRight itemPrice">((Value))</td>
     <td class="currencyLeft" style="width:10%;" >((Currency ))</td>
 </tr>
 <tr class="spaceUnder"><td colspan="3"> </td></tr>
 <tr >
    <td colspan="3">
    <select title="serviceProvidersSelect" name="serviceProvidersSelect" id="serviceProvidersSelect" class="selectBank" disabled>
        <option value="none" selected disabled hidden>((LanguageNamespace.GetStringAsync(9) ))</option>
      </select>
   </td>
 </tr>
 </table>

</div>

<div class="spaceItem"></div>

 <form id="payment-form">
        <div id="link-authentication-element">
        </div>
        <div id="payment-element">
        </div>
        <div class="spinner hidden" id="spinner"></div>
        <div class="stripe-submit-div">
          <div class="spinner hidden" id="spinner"></div>
           <button id="stripe-submit" class="stripe-button stripe-hide" type="submit" >Pay now</button>
        </div>
      </form>
<div id="QrCode"></div>
<div id="spinnerContainer">
  <img src="./resources/spinner.gif" alt="loadingSpinner">
</div>

[[
)
else if ContractState == "PaymentCompleted" then 
(
]]**((LanguageNamespace.GetStringAsync(16) ))**[[
)
else if ContractState == "PaymentCanceled" then 
(
]]**((LanguageNamespace.GetStringAsync(14) ))**ed[[
)
else 
(
]]**((LanguageNamespace.GetStringAsync(23) ))**[[
)

}}

</div>

</main>
<div class="footer-parent">
  <div class="footer">
   Powrs AB, (org.no 559302-8045), Hammarbybacken 27, Stockholm <br/>Sweden ©2021 - 2023 POWRS 
  </div>
</div>