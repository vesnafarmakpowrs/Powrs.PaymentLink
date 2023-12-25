Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/Payout.cssx
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: lng
JavaScript: js/Events.js
JavaScript: js/PaymentLink.js

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
if ContractState == "AwaitingForPayment" then 
(
    Contract:=select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId=ID;
   
    if !exists(Contract) then
    (
	 ]]<b>Payment link is not valid</b>[[;
         Return("");
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

    foreach Variable in (CurrentState.VariableValues ?? []) do 
      (
        Variable.Name like "Title" ?   Title := Variable.Value;
        Variable.Name like "Description" ?   Description := Variable.Value;
        Variable.Name like "Price" ?   ContractValue := Variable.Value.ToString("N2");
        Variable.Name like "Currency" ?   Currency := Variable.Value;
        Variable.Name like "Country" ?   Country := Variable.Value.ToString();
        Variable.Name like "Commission" ?   Commission := Variable.Value;
        Variable.Name like "Buyer" ?   BuyerFullName := Variable.Value;
        Variable.Name like "BuyerEmail" ?  BuyerEmail := Variable.Value;
        Variable.Name like "BuyerPersonalNum" ?   BuyerPersonalNum := Variable.Value;
        Variable.Name like "EscrowFee" ?   EscrowFee := Variable.Value.ToString("N2");
        Variable.Name like "AmountToPay" ?   AmountToPay := Variable.Value.ToString("N2");
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
                "pnr": BuyerPersonalNum,
                "country": Country,
                "exp": NowUtc.AddMinutes(tokenDurationInMinutes)
            });

      ]]  <table style="width:100%">
         <tr class="welcomeLbl">   
         <td><img class="vaulterLogo" src="./resources/vaulter_txt.svg" alt="Vaulter"/> </td>
    <td coolspan="2">
       <select class="select-lng" title="languageDropdown" id="languageDropdown"></select></td>
  </tr>
   <tr>
     <td>**((LanguageNamespace.GetStringAsync(36) ))</td>
</tr>
</table>

<input type="hidden" value="((lng ))" id="prefferedLanguage"/>
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

<input type="hidden" value="((Request.RemoteEndPoint))" id="currentIp"/>
<input type="hidden" value="((BuyerFullName))" id="buyerFullName"/>
<input type="hidden" value="((BuyerEmail))" id="buyerEmail"/>
<input type="hidden" value="((FileName))" id="fileName"/>
<input type="hidden" value="((Country ))" id="country"/>

<div class="payment-details">
  <table style="width:100%">
    <tr id="tr_header" class="table-row">
      <td class="item-header"><strong>((LanguageNamespace.GetStringAsync(39) ))<strong></td>
      <td class="price-header"><strong>((LanguageNamespace.GetStringAsync(40) ))<strong></td>
    </tr>
    <tr id="tr_header_title">
      <td colspan="2" class="item border-radius">
        <table style="vertical-align:middle; width:100%;">
          <tr>
            <td style="width:80%;"> ((Title))</td>
            <td class="itemPrice" rowspan="2">((ContractValue))
            <td>
            <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
          </tr>
          <tr>
            <td style="width:70%"> ((Description))</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr id="tr_space" class="spaceUnder">
      <td colspan="2"></td>
    </tr>
    <tr id="tr_fees" class="spaceUnder">
      <td colspan="2" class="item border-radius">
        <table style="vertical-align:middle; width:100%;">
          <tr>
            <td style="width:80%">((LanguageNamespace.GetStringAsync(21) ))</td>
            <td class="itemPrice" rowspan="2">((EscrowFee))
            <td>
            <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
          </tr>
        </table>
      </td>
    </tr>
    <tr class="spaceUnder">
      <td colspan="2"></td>
    </tr>
    <tr id="tr_summary">
      <td colspan="2" class="item border-radius">
        <table style="vertical-align:middle; width:100%;">
          <tr>
            <td style="width:80%">**((LanguageNamespace.GetStringAsync(20) ))**</td>
            <td class="itemPrice" rowspan="2">((AmountToPay))
            <td>
            <td style="width:10%;" rowspan="2" class="currencyLeft"> ((Currency )) </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</div>
<div class="spaceItem"></div>
<div class="vaulter-details">
<table style="width:100%">

 <tr >
  <td colspan="3">
     <input type="checkbox" id="termsAndCondition" name="termsAndCondition" onclick="UserAgree();"> 
     <label for="termsAndCondition"> 
        <img class="logo_small" for="termsAndCondition" src="./resources/vaulter_txt.svg" alt="Vaulter"/> 
        <a href="TermsAndCondition.html" target="_blank">**((LanguageNamespace.GetStringAsync(19) ))**</a></label>    
 </td>
 </tr>
 </table>
</div>
<div class="spaceItem"></div>
<div id="left-to-pay" style="display:none">
  <label class=""><strong>((LanguageNamespace.GetStringAsync(37) ))</strong></label>
</div>

<div class="payment-method-rs"  id="ctn-payment-method-rs" style="display:none">
  <table style="width:100%; text-align:center">
    <tr>
      <td>
        <button id="payspot-submit" class="stripe-button" disabled="disabled" onclick="StartPayment()">Pay now</button>
      </td>
    </tr>
    <tr id="tr_spinner" style="display: none;">
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
</div>
   [[;
)
else if ContractState == "PaymentCompleted" then 
(
]]**((LanguageNamespace.GetStringAsync(16) ))**[[;
)
else if ContractState == "PaymentCanceled" then 
(
]]**((LanguageNamespace.GetStringAsync(14) ))**ed[[;
)
else 
(
]]**((LanguageNamespace.GetStringAsync(23) ))**[[;
)



}}

</div>
</main>

<div class="footer-parent">
  <div class="footer">
   Powrs AB, (org.no 559302-8045), Hammarbybacken 27, Stockholm <br/>Sweden ©2021 - 2023 POWRS 
  </div>
</div>
</div>