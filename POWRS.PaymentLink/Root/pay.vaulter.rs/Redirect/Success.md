Title: Payment Link Success
Description: Displays information about a contract.
Date: 2023-12-06
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../css/Status.css
Parameter: lng
viewport : Width=device-width, initial-scale=1

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
{{
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
]] <div class="container">
        <div class="messageContainer messageContainer_width">
            <div class="imageContainer">
                <img src="../resources/success_green.png" alt="successpng" width="50" />
            </div>
            <div class="welcomeLbl textHeader">
                <span>((LanguageNamespace.GetStringAsync(50) ))</span>
            </div>
            <div class="textBody">
                <span>((LanguageNamespace.GetStringAsync(51) ))</span>
            </div>
        </div>
    </div>
[[;
}}
</main>