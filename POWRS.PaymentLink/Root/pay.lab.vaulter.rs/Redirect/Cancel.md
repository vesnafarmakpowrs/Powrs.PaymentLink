Title: Payment Link Cancel
Description: Displays information about a contract.
Date: 2023-12-06
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../css/Status.css
CSS: ../css/Payout.cssx
viewport : Width=device-width, initial-scale=1

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
{{
 lng:= "rs";
 Language:= Translator.GetLanguageAsync("rs");
 LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
]]
<div class="container">
        <div class="messageContainer messageContainer_width">
            <div class="imageContainer">
                <img src="../resources/error_red.png" alt="successpng" width="50" />
            </div>
            <div class="welcomeLbl textHeader">
                <span>((LanguageNamespace.GetStringAsync(48) ))</span>
            </div>
        </div>
    </div>
[[;
}}
</main>