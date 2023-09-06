Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: Vesna Farmak
Cache-Control: max-age=0, no-cache, no-store
CSS: Payout.cssx
Javascript: /Contract.js
Parameter: ID
Parameter: Language
JavaScript: Events.js
JavaScript: Tests.js
JavaScript: OutgoingPayments.js


<title>Document</title></head>
<main class="border-radius"  >
<b><h2>Welcome to Vaulter checkout</h2></b>

<table style="width:100%">
<tr>
<td>
Protect your money with smart payments 
</td>
<td rowspan="2"><img style="width:30px;" src="vaulterlogo.svg" alt="Vaulter"/> </td>
<tr>

</tr>
</tr></table>

{{

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
    SellerId := SellerName.Substring(0,3).ToUpper(); 

    FileName:= SellerId + Token.ShortId;


    foreach Parameter in (Contract.Parameters ?? []) do 
      (
        Parameter.Name like "Title" ?   Title := Parameter.MarkdownValue;
        Parameter.Name like "Description" ?   Description := Parameter.MarkdownValue;
        Parameter.Name like "Value" ?   Value := Parameter.MarkdownValue;
        Parameter.Name like "Currency" ?   Currency := Parameter.MarkdownValue;
        Parameter.Name like "Commission" ?   Commission := Parameter.MarkdownValue;
        Parameter.Name like "BuyerFullName" ?   BuyerFullName := Parameter.MarkdownValue;
        Parameter.Name like "BuyerEmail" ?  BuyerEmail := Parameter.MarkdownValue;
        Parameter.Name like "BuyerPersonalNum" ?   BuyerPersonalNum := Parameter.MarkdownValue;
        Parameter.Name like "EscrowFee" ?   EscrowFee := Parameter.MarkdownValue;
        Parameter.Name like "AmountToPay" ?   AmountToPay := Parameter.MarkdownValue;
      );

]]**
<input type="hidden" value="((Contract.ContractId))" id="contractId"/>
<input type="hidden" value="((BuyerPersonalNum))" id="personalNumber"/>
<input type="hidden" value="((FileName))" id="fileName"/>


**Name** : ((MarkdownEncode(BuyerFullName) )) <br/>
**Email address**:  ((BuyerEmail ))<br/>
<br/>

<div class="item border-radius">
<table style="vertical-align:middle; height:100%;">
 <tr><td style="width:80%"> ((Title))</td>
 <td class="itemPrice"  rowspan="2" > <div class="price">((Value ))</div> <td>
 <td style="width:10%;" rowspan="2" > ((Currency )) </td>
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
        <td style="width:80%">Administration and protection fee</td>
        <td class="itemPrice"  rowspan="2" ><div class="price">((EscrowFee))</div> <td>
        <td style="width:10%;" rowspan="2" > ((Currency )) </td>
      </tr>
</table>
</div>
  
<div class="spaceItem"></div>

<table style="width:100%">
<tr>
  <td style="width:50%"></td>
  <td style="width:50%">
     <div class="total border-radius">
      <table style="vertical-align:middle; height:100%;">
     <tr>
        <td style="width:70%">Total to pay</td>
        <td class="itemPrice"  rowspan="2" ><div class="price">((AmountToPay)) </div> <td>
        <td style="width:10%;" rowspan="2" > ((Currency )) </td>
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
   <input type="checkbox" id="termsAndCondition" name="termsAndCondition">
   <label for="termsAndCondition"><a href="https://www.powrs.se/vaulter-payment-link-privacy-policy" target="_blank">Terms ans conditions</a></label> 
</div><br/>
<div>
   <input type="checkbox" id="purchaseAgreement" name="purchaseAgreement">
   <label for="purchaseAgreement"><a href="#" onclick="generatePDF();event.preventDefault();" >Purchase Agreement</a></label> 
</div>

<div class="spaceItem"></div>

<select title="serviceProvidersSelect" name="serviceProvidersSelect" id="serviceProvidersSelect" class="border-radius">
</select>

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


}}

</main>
