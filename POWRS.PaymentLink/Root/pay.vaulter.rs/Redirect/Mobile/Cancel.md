Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../../css/Payout.cssx
CSS: ../../css/Status.css
viewport : Width=device-width, initial-scale=1
Parameter: ORDERID

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container">
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

    Country:= select top 1 Value from CurrentState.VariableValues where Name = "Country";
    culture:= Country == "RS" ? "sr" : "en";
	localization:= Create(POWRS.PaymentLink.Localization.LocalizationService, Create(CultureInfo, culture), "Payout");
]]
<div class="spaceItem"></div>
 <div class="vaulter-details container">
        <div class="messageContainer messageContainer_width">
            <div class="imageContainer">
                <img src="../../resources/error_red.png" alt="successpng" width="50" />
            </div>
            <div class="welcomeLbl textHeader">
                <span>((localization.Get("TransactionCanceled") ))</span>
            </div>
        </div>
    </div>
</div>
</div>
</main>
<div class="footer-parent">
  <div class="footer">
    Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - ((Now.Year)) POWRS
  </div>
</div>
</div>[[;
}}