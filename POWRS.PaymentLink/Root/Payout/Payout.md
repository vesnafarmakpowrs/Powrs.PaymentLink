Title: Contract
Description: Displays information about a contract.
Date: 2020-02-18
Author: Peter Waher
Cache-Control: max-age=0, no-cache, no-store
CSS: Payout.cssx
CSS: /css/base.css
Javascript: /Contract.js
Parameter: ID
Parameter: Language
JavaScript: Events.js
JavaScript: Tests.js
JavaScript: OutgoingPayments.js

<title>Document</title></head>

<header id="header">
<nav>

* Vaulter checkout
</nav>
</header>

<main style="width:650px; margin-left:auto; margin-right: auto;padding-top:50px; background-color:white;" >

<br/>
<div class="title1" ></div>Welcome to Vaulter checkout

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
CS:=IoTBroker.Legal.Contracts.ContractState;
MinDT:=System.DateTime.MinValue;
MaxDT:=System.DateTime.MaxValue;

OneRow(s):=
(
	s.Replace("\r\n","\n").Replace("\n","<br/>")
);


ID += "@legal." + Gateway.Domain; 
Contract:=select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId=ID;
if !exists(Contract) then 
	NotFound("Contract not found.")
else
(
	v:=Create(Waher.Script.Variables,[]);
	foreach Parameter in Contract.Parameters do Parameter.Populate(v);
	foreach Parameter in Contract.Parameters do Parameter.IsParameterValid(v);
);
    foreach Parameter in (Contract.Parameters ?? []) do 
      (
        Parameter.Name like "Title" ?   Title := Parameter.MarkdownValue;
        Parameter.Name like "Description" ?   Description := Parameter.MarkdownValue;
        Parameter.Name like "Value" ?   Value := Parameter.MarkdownValue;
        Parameter.Name like "Currency" ?   Currency := Parameter.MarkdownValue;
        Parameter.Name like "Commission" ?   Commission := Parameter.MarkdownValue;
        Parameter.Name like "BuyerFullName" ?   BuyerFullName := Parameter.MarkdownValue;
        Parameter.Name like "BuyerPersonalNum" ?   BuyerPersonalNum := Parameter.MarkdownValue;
	    Parameter.Name like "EscrowFee" ?   EscrowFee := Parameter.MarkdownValue;
        Parameter.Name like "AmountToPay" ?   AmountToPay := Parameter.MarkdownValue;
      );
null
}}

{{]]

<input type="hidden" value="((Contract.ContractId))" id="contractId"/>
<input type="hidden" value="((BuyerPersonalNum))" id="personalNumber"/>

Sold by **((Contract.Account)) ** <br/>
**Payer** :<br/>
**Name** : ((MarkdownEncode(BuyerFullName) )) <br/>
**Email address**: (()) <br/>
<br/>

<div class="item">
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


<div class="item">
     <table style="vertical-align:middle; height:100%;">
      <tr>
        <td style="width:80%">Administration and protection fee</td>
        <td class="itemPrice"  rowspan="2" ><div class="price">((EscrowFee))</div> <td>
        <td style="width:10%;" rowspan="2" > ((Currency )) </td>
      </tr>
      <tr>
        <td style="width:70%"> ((Description))</td>
      </tr>
</table>
</div>
  
<div class="spaceItem"></div>

<table style="width:100%">
<tr>
  <td style="width:50%"></td>
  <td style="width:50%">
     <div class="total">
      <table style="vertical-align:middle; height:100%;">
     <tr>
        <td style="width:70%">Total to pay</td>
        <td class="itemPrice"  rowspan="2" ><div class="price">((AmountToPay)) </div> <td>
        <td style="width:10%;" rowspan="2" > ((Currency )) [[}} </td>
    </tr>
 <tr>
  <td style="width:70%"> </td>
 </tr>
</table>

</div>
</td>
<tr>
<table>

<div>Pay and protect your deal with<div><br/>
<img style="height:40px;" src="vaulter_logo.svg" alt="Vaulter"/> 

</div>

<div>
   <input type="checkbox" id="purchaseAgreement" name="purchaseAgreement">
   <label for="purchaseAgreement"><a>Purchase Agreement</a></label> 
</div>

<div class="spaceItem"></div>


<select id="serviceProvidersSelect">
</select>


````async:Preparing authentication...


]]

<div class="spaceItem"></div>
<div class="spaceItem"></div>
[[;

null
````

<div style='display:none;' id="TestStatus"></div>
<div id="QrCode"></div>

</main>
