Title: Payment Link
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

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div>
<div class="content">
{{

Order := select top 1 * from PayspotPayments where OrderId = ORDERID;
TokenID := Order.TokenId;
ID := Order.ContractId;

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
    (
        ContractState:= CurrentState.State;
    );		
);

    Contract:= select top 1 * from IoTBroker.Legal.Contracts.Contract where ContractId= Token.OwnershipContract;
   
    if !exists(Contract) then
    (
	 ]]<b>Payment link is not valid</b>[[;
         Return("");
    );

    Identity:= select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = Contract.Account And State = 'Approved';
    AgentName := Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST;
    OrgName  := Identity.ORGNAME;

    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;
    SellerId := UpperCase(SellerName.Substring(0,3)); 

    RedirectUrl:= select top 1 Value from CurrentState.VariableValues where Name = "ErrorUrl";
    Title:= select top 1 Value from CurrentState.VariableValues where Name = "Title";
    Description:= select top 1 Value from CurrentState.VariableValues where Name = "Description";
    Currency:= select top 1 Value from CurrentState.VariableValues where Name = "Currency";
    Country:= select top 1 Value from CurrentState.VariableValues where Name = "Country";
    BuyerFullName:= select top 1 Value from CurrentState.VariableValues where Name = "Buyer";

    culture:= Country == "RS" ? "sr" : "en";
	localization:= Create(POWRS.PaymentLink.Localization.LocalizationService, Create(CultureInfo, culture), "Payout");

     BuyerFirstName := Before(BuyerFullName," ");
      ]]  <table style="width:100%">
         <tr class="welcomeLbl">   
         <td><img class="vaulterLogo" src="../../resources/vaulter_txt.svg" alt="Vaulter"/> </td>
    <td coolspan="2">
       <select class="select-lng" style="display:none" title="languageDropdown" id="languageDropdown"></select></td>
  </tr>
   <tr>
    <td>**((localization.GetFormat("HelloUser", BuyerFullName) ))**</td>
</tr>
</table>

<input type="hidden" value="((Country ))" id="prefferedLanguage"/>
<input type="hidden" value="POWRS.PaymentLink" id="Namespace"/>

<input type="hidden" value="((localization.Get("PaymentSuccessfulThankYou") ))" id="TransactionCompleted"/>
<input type="hidden" value="((localization.Get("PaymentNoPaymentNotPossibletPossible") ))" id="TransactionFailed"/>
<input type="hidden" value="((localization.Get("PaymentInProgress") ))" id="TransactionInProgress"/>

<input type="hidden" value="((Country ))" id="country"/>
<input type="hidden" value="((RedirectUrl ))" id="RedirectUrl"/>

<div class="payment-details">
  <table style="width:100%">
    <tr id="tr_header" class="table-row">
      <td class="item-header"><strong>((localization.Get("Product") ))<strong></td>
      <td class="price-header"><strong>((localization.Get("Price") ))<strong></td>
    </tr>
    <tr id="tr_header_title">
      <td colspan="2" class="item border-radius">
        <table style="vertical-align:middle; width:100%;">
          <tr>
            <td style="width:80%;"> ((Title))</td>
            <td class="itemPrice" rowspan="2">((Order.Amount.ToString("N2") ))
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
            <td style="width:80%">**((localization.Get("TotalAmount") ))**</td>
            <td class="itemPrice" rowspan="2">((Order.Amount.ToString("N2") ))
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
                <span>((localization.Get("TransactionFailed") ))</span>
            </div>[[;
            if(!System.String.IsNullOrEmpty(SuccessUrl)) then
            (
             ]]<div class="textBody">
                <h3 style="color: red;">((localization.Get("RedirectToSellerPage") ))</h3>
             </div>[[;
            );
        ]]
        </div>
     </div>
    </div>
</div>
</main>
<div class="footer-parent">
  <div class="footer">
    Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - ((Now.Year )) POWRS
  </div>
</div>
</div>[[;
}}