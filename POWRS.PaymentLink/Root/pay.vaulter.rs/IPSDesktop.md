Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/IPS.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: JWT
JavaScript: js/Events.js
JavaScript: js/QRIPS.js
JavaScript: js/XmlHttp.js

<main class="main page-padding ips">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
   {{
     SessionToken:= ValidateJwt(JWT);
     Lng := SessionToken.Claims.language;
     Language:= Translator.GetLanguageAsync(Lng);
     LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
     ]]<div class="container">
              <div class="content"> 
                   <div class="article">    
                        <div class="div-logo-ips">
                            <img src="./resources/ipslogo.png" alt="ipsLogoScan"/>
                            <img src="./resources/vaulter_logo.webp" alt="VaulterLogo"/>
                        </div>    
                        <div><label>((LanguageNamespace.GetStringAsync(68) ))</label> </div>
                   </div> 
                   <div class="div-ips-code">
                      <div> 
                          <img id="QRCode" src="" alt="" />
                      </div>
                      <div class="qr-timer">
                          <strong><div class="pomView" timer id="timer"></div></strong>
              	      </div>   
                      <div class="gen-wrap">
                          <div id="msg-time-expire" class="msg">((LanguageNamespace.GetStringAsync(69) ))</div>
                          <div id="msg-generate-qrcode" class="msg">((LanguageNamespace.GetStringAsync(70) ))</div>
                          <div class="pay-div" display="none"><button id="btnGenerateQR" class="pay-btn btn-black btn-hide" onclick="getQRCode()">((LanguageNamespace.GetStringAsync(71) ))</button> </div>
                          <div class="cancel-div"><button  id="btnCancelQR"  onclick="cancelTransaction()"  type="button" class="pay-btn btn-grey btn-hide" id="cancel_btn">((LanguageNamespace.GetStringAsync(72) ))</button></div>
                      </div> 
                  </div>
                </div>           
        </div>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(27) ))" id="TransactionCompleted"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(28) ))" id="TransactionFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(29) ))" id="TransactionInProgress"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(47) ))" id="SessionTokenExpired"/>[[
}}
</main>
