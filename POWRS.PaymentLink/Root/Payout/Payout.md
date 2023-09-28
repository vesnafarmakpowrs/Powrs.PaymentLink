Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Cache-Control: max-age=0, no-cache, no-store
CSS: Payout.cssx
Parameter: ID
Parameter: lan
JavaScript: Events.js
JavaScript: PaymentLink.js

<main class="border-radius">
<div class="content">
<b><h2></h2></b>
{{

 Language:= null;
if(exists(lan)) then 
(
  Language:= Translator.GetLanguageAsync(lan);
);
if(Language == null) then 
(
 lan:= "sv";
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

]]
<table style="width:100%">
  <tr class="welcomeLbl">     
    <td>**((LanguageNamespace.GetStringAsync(22) ))**    
    </td>
    <td rowspan="3"><img class="vaulterLogo" src="vaulterlogo.svg" alt="Vaulter"/> </td>
  </tr>
  <tr>
    <td>
       ((LanguageNamespace.GetStringAsync(6) ))
    </td>
  </tr>
 <tr>
    <td>
    </td>
  </tr>
</table>

<input type="hidden" value="((LanguageNamespace.GetStringAsync(10) ))" id="SelectedAccountOk"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(24) ))" id="SelectedAccountNotOk"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(25) ))" id="QrCodeScanMessage"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(26) ))" id="QrCodeScanTitle"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(27) ))" id="TransactionCompleted"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(28) ))" id="TransactionFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(29) ))" id="TransactionInProgress"/>

<input type="hidden" value="((Contract.ContractId))" id="contractId"/>
<input type="hidden" value="((BuyerPersonalNum))" id="personalNumber"/>
<input type="hidden" value="((FileName))" id="fileName"/>

**((LanguageNamespace.GetStringAsync(4) ))** : ((MarkdownEncode(BuyerFullName) )) <br/>

**((LanguageNamespace.GetStringAsync(3) ))**:  ((BuyerEmail ))<br/>
<br/>

**((LanguageNamespace.GetStringAsync(12) ))**<br>
((SellerName))**

<div class="item border-radius">
<table style="vertical-align:middle; height:100%;">
 <tr><td style="width:80%"> ((Title))</td>
 <td class="itemPrice"  rowspan="2" > <div class="price">((Value ))</div> <td>
 <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
</tr>
 <tr>
  <td style="width:70%"> ((Description))</td>
 </tr>
</table>
</div>
<div class="spaceItem"></div>


<div class="item border-radius">
     <table style="vertical-align:middle; height:100%;">
      <tr>
        <td style="width:80%">((LanguageNamespace.GetStringAsync(21) ))</td>
        <td class="itemPrice"  rowspan="2" ><div class="price">((EscrowFee))</div> <td>
        <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
      </tr>
</table>
</div>
  
<div class="spaceItem"></div>

<table style="width:100%">
<tr>
  <td style="width:40%"></td>
  <td style="width:60%">
     <div class="total border-radius">
      <table style="vertical-align:middle; height:100%;">
        <tr>
         <td style="width:70%">((LanguageNamespace.GetStringAsync(20) ))</td>
         <td class="itemPrice"  rowspan="2" ><div class="price">((AmountToPay)) </div> <td>
         <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
        </tr>
        <tr>
         <td style="width:70%"> </td>
        </tr>
</table>

</div>
</td>
<tr>
<table>

</div>
<div>
   <input type="checkbox" id="termsAndCondition" name="termsAndCondition" onclick="UserAgree();">
   <label for="termsAndCondition"><a href="https://www.powrs.se/terms-and-conditions-payment-link" target="_blank">**((LanguageNamespace.GetStringAsync(19) ))**</a></label> 
</div>
<div class="spaceItem"></div>
<div>
   <input type="checkbox" id="purchaseAgreement" name="purchaseAgreement" onclick="UserAgree();">
   <label for="purchaseAgreement"><a href="#" onclick="generatePDF();event.preventDefault();" >**((LanguageNamespace.GetStringAsync(7) ))**</a></label> 
</div>

<table style="width:100%">
 <tr>
  <td style="width:100%">
     <div class="total border-radius vaulterDiv">
      <table style="vertical-align:middle; height:100%;">
        <tr>
         <td style="width:80%">((LanguageNamespace.GetStringAsync(1) ))</td>
         <td class="moneyRight itemPrice">((Value))</td>
         <td class="currencyLeft" style="width:10%;" >((Currency ))</td>
        </tr>
      </table>
     </div>
   </td>
 <tr>

<table style="width:100%">
 <tr>
  <td style="width:100%">
    <div class="selectBankDiv">
      <select title="serviceProvidersSelect" name="serviceProvidersSelect" id="serviceProvidersSelect" class="selectBank" disabled>
        <option value="none" selected disabled hidden>((LanguageNamespace.GetStringAsync(9) ))</option>
      </select>
    </div>
  </td>
  </tr>
</table>

<div id="QrCode"></div>
<div id="spinnerContainer">
  <img src="./spinner.gif" alt="loadingSpinner">
</div>

[[
)
else if ContractState == "PaymentCompleted" then 
(
]]**((LanguageNamespace.GetStringAsync(16) ))**[[
)
else if ContractState == "Cancel" then 
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