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
Parameter: lng

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
]]
<div class="spaceItem"></div>
 <div class="vaulter-details container">
        <div class="messageContainer messageContainer_width">
            <div class="imageContainer">
                <img src="../../resources/error_red.png" alt="successpng" width="50" />
            </div>
            <div class="welcomeLbl textHeader">
                <span>((LanguageNamespace.GetStringAsync(48) ))</span>
            </div>
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