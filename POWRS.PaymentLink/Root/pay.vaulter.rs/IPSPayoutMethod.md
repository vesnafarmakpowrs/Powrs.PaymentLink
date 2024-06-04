Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/IPS.cssx
CSS: css/Info.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: JWT
JavaScript: js/IPSPayment.js

<main class="main page-padding content-ips-method">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
{{
   SessionToken:= ValidateJwt(JWT);
   Lng := SessionToken.Claims.language;
   Language:= Translator.GetLanguageAsync(Lng);
   LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
    ]]<div class="container">
                   <div >
                          <div class="pay-div pay-div-header" >
                             <label>((LanguageNamespace.GetStringAsync(67) ))</label>
			     <img src="resources\info.png" class="img-info" onclick="infoPopup()"/> 
                          </div>
                          <div class="pay-div" ><button class="pay-btn btn-black" onclick="getbanksIE()">((LanguageNamespace.GetStringAsync(63) ))</button> </div>
                          <div class="pay-div" ><button class="pay-btn btn-grey" onclick="getbanksLE()">((LanguageNamespace.GetStringAsync(64) ))</button></div>
                 </div>
        <div id="popupOverlay" class="overlay-container"> 
        <div class="popup-box"> 
            <h2 style="color: green;"></h2> 
            <form class="form-container"> 
                <label class="form-label">((LanguageNamespace.GetStringAsync(65) ))</label> 
            </form> 
            <button class="btn-close-popup pay-btn btn-black" onclick="infoPopup()">((LanguageNamespace.GetStringAsync(66) ))</button> 
        </div> 
    </div> 
    </div>
    <input type="hidden" value="((JWT ))" id="jwt"/>[[;
}}
</main>
