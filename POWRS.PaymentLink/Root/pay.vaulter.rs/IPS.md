Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
Pragma: no-cache
Expires: 0
CSS: css/Payout.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: lng
JavaScript: js/Events.js
JavaScript: js/IPS.js


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
     
    CompanyInfo := select top 1 * from POWRS.PaymentLink.Models.OrganizationContactInformation where OrganizationName = OrgName;
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
    foreach Parameter in (Contract.Parameters ?? []) do 
    (
          if Parameter.Name == 'RemoteId' then RemoteId := MarkdownEncode(Parameter.Value);
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

     ]]  

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
<input type="hidden" value="((LanguageNamespace.GetStringAsync(74) ))" id="PaymentFailed"/
<input type="hidden" value="true" id="IpsOnly"/>
<input type="hidden" value="((Request.RemoteEndPoint))" id="currentIp"/>
<input type="hidden" value="((BuyerFullName))" id="buyerFullName"/>
<input type="hidden" value="((BuyerEmail))" id="buyerEmail"/>
<input type="hidden" value="((FileName))" id="fileName"/>
<input type="hidden" value="((Country ))" id="country"/>

[[;
if ContractState == "AwaitingForPayment" then 
(
]]
  <iframe scrolling="no" id="ips-iframe" ></iframe>
<div class="spaceItem"></div>
<div id="retry-payment" style="display:none">
   <div class="retry-div" >
    <button id="payspot-submit" class="retry-button" onclick="RetryPayment()">((LanguageNamespace.GetStringAsync(75) ))</button> 
  </div>
</div>
<div id="payment-msg-div"  style="display:none">
   <div id="payment-msg" class="retry-div" ></div>
</div>
<div class="payment-method-rs"  id="ctn-payment-method-rs" style="display:none">
  <table class="payment-method-tbl-rs">
    <tr>
     <td style="vertical-align: top;">
    
     </td>
   </tr>
   <tr id="tr_spinner" style="display: none;">
     <td>
       <img src="../resources/spin.svg" alt="loadingSpinner">
     </td>
   </tr>
</table>
</div>[[;
)
else if (ContractState == "PaymentCompleted" || ContractState == "ServiceDelivered" || ContractState == "Done" )then 
(
]]<div class="payment-completed">**((LanguageNamespace.GetStringAsync(16) ))**</div>[[;
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
   Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - 2024 POWRS
  </div>
</div>
</div>