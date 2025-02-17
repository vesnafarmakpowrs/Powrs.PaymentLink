﻿Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../../css/Payout.cssx
CSS: ../../css/Status.css
JavaScript: ../../js/Status.js
viewport : Width=device-width, initial-scale=1
Parameter: ORDERID
Parameter: lng

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div>
<div class="content">
{{

Order := select top 1 OrderId, ContractId, TokenId from PayspotPayments where OrderId = ORDERID;
TokenID := Order.TokenId[0];
ID := Order.ContractId[0];

Token := select top 1 * from IoTBroker.NeuroFeatures.Token where TokenId=TokenID;
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

    Contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= Token.OwnershipContract;
   
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

    RedirectUrl:= "";
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
        Variable.Name like "ErrorUrl" ?  RedirectUrl := Variable.Value.ToString();
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

     BuyerFirstName := Before(BuyerFullName," ");
      ]]  <table style="width:100%">
         <tr class="welcomeLbl">   
         <td><img class="vaulterLogo" src="../../resources/vaulter_txt.svg" alt="Vaulter"/> </td>
    <td coolspan="2">
       <select class="select-lng" style="display:none" title="languageDropdown" id="languageDropdown"></select></td>
  </tr>
   <tr>
    <td>**((System.String.Format(LanguageNamespace.GetStringAsync(36).ToString(), BuyerFullName) ))**</td>
</tr>
</table>

<input type="hidden" value="((lng ))" id="prefferedLanguage"/>
<input type="hidden" value="POWRS.PaymentLink" id="Namespace"/>

<input type="hidden" value="((LanguageNamespace.GetStringAsync(27) ))" id="TransactionCompleted"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(28) ))" id="TransactionFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(29) ))" id="TransactionInProgress"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(30) ))" id="OpenLinkOnPhoneMessage"/>

<input type="hidden" value="((Country ))" id="country"/>
<input type="hidden" value="((RedirectUrl ))" id="RedirectUrl"/>

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
    <tr class="spaceUnder">
      <td colspan="2"></td>
    </tr>
    <tr id="tr_summary">
      <td colspan="2" class="item border-radius">
        <table style="vertical-align:middle; width:100%;">
          <tr>
            <td style="width:80%">**((LanguageNamespace.GetStringAsync(55) ))**</td>
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
        <div class="messageContainer messageContainer_width">
          <div class="messageContainer messageContainer_width">
            <div class="imageContainer">
                <img src="../../resources/error_red.png" alt="successpng" width="50" />
            </div>
            <div class="welcomeLbl textHeader">
                <span>((LanguageNamespace.GetStringAsync(49) ))</span>
            </div>[[;
            if(!System.String.IsNullOrEmpty(SuccessUrl)) then 
            (
             ]]<div class="textBody">
                <h3 style="color: red;">((LanguageNamespace.GetStringAsync(77) ))</h3>
             </div>[[;
            );
        ]]
        </div>
     </div>
    </div>[[;
}}

</div>
</main>

<div class="footer-parent">
  <div class="footer">
    Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - 2024 POWRS
  </div>
</div>
</div>