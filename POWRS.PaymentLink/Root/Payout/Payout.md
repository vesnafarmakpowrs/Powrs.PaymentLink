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

<title>Document</title></head>

<main class="border-radius"  >
<div class="content">
<b><h2></h2></b>

<table style="width:100%">
  <tr class="welcomeLbl">
    <td>Welcome to Vaulter checkout
    </td>
    <td rowspan="3"><img class="vaulterLogo" src="vaulterlogo.svg" alt="Vaulter"/> </td>
  </tr>
  <tr>
    <td>
       Protect your money with smart payments 
    </td>
  </tr>
 <tr>
    <td>
    </td>
  </tr>
</table>

{{

Language:= null;
if(exists(lan)) then 
(
  Language:= Translator.GetLanguageAsync(lan);
);
if(Language == null) then 
(
 Language:= Translator.GetLanguageAsync("en");
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

]]**
<input type="hidden" value="((Contract.ContractId))" id="contractId"/>
<input type="hidden" value="((BuyerPersonalNum))" id="personalNumber"/>
<input type="hidden" value="((FileName))" id="fileName"/>

**((LanguageNamespace.GetStringAsync(4) ))** : ((MarkdownEncode(BuyerFullName) )) <br/>
**Email address**:  ((BuyerEmail ))<br/>
<br/>

**Sold by<br>
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
        <td style="width:80%">Vaulter service fee</td>
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
         <td style="width:70%">Total to pay</td>
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
   <label for="termsAndCondition"><a href="https://www.powrs.se/terms-and-conditions-payment-link" target="_blank">Terms and conditions</a></label> 
</div>
<div class="spaceItem"></div>
<div>
   <input type="checkbox" id="purchaseAgreement" name="purchaseAgreement" onclick="UserAgree();">
   <label for="purchaseAgreement"><a href="#" onclick="generatePDF();event.preventDefault();" >Purchase Agreement</a></label> 
</div>

<table style="width:100%">
 <tr>
  <td style="width:100%">
     <div class="total border-radius vaulterDiv">
      <table style="vertical-align:middle; height:100%;">
        <tr>
         <td style="width:80%">The amount safeguarded by Vaulter until the end of the cancelation period set by the seller</td>
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
]]**((ContractState))**[[
)
else if ContractState == "Cancel" then 
(
]]**((ContractState))**ed[[
)
else 
(
]]**Payment link has expired. Please contact the seller to receive a new one.**[[
)

}}

</div>

</main>
<div class="footer-parent">
  <div class="footer">
   Powrs AB, (org.no 559302-8045), Hammarbybacken 27, Stockholm <br/>Sweden ©2021 - 2023 POWRS 
  </div>
</div>