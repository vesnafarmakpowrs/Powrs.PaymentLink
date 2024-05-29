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
JavaScript: js/Events.js
JavaScript: js/QRIPS.js

<main class="main page-padding ips">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
   {{
      Language:= null;
	    if (exists(lng)) then Language:= Translator.GetLanguageAsync(lng);
           
            if(Language == null) then 
            (
               lng:= "rs";
               Language:= Translator.GetLanguageAsync("rs");
             );
           LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
     ]]<div class="container">
              <div class="content"> 
                   <div class="article">    
                        <div class="div-logo-ips">
                            <img src="./resources/ipslogo.png" alt="ipsLogoScan"/>
                            <img src="./resources/vaulter_logo.webp" alt="VaulterLogo"/>
                        </div>    
                        <div><label>Mbanking aplikacijom koju imate instaliranu na svom mobilnom uređaju skenirajte prikazani jednokratan IPS QR kod i izvršite plaćanje u okruženju Vaše banke. Informacija o ishodu plaćanja biće Vam prikazana odmah po završetku obrade ali će Vam biti dostavljena i na e-mail adresu uz potvrdu o kupovini.</label> </div>
                   </div> 
                   <div class="div-ips-code">
                      <div> 
                          <img id="QRCode" src="" alt="" />
                      </div>
                      <div class="qr-timer">
                          <strong><div class="pomView" timer id="timer"></div></strong>
              	      </div>   
                      <div class="gen-wrap">
                          <div id="msg-time-expire" class="msg"> Vreme je isteklo</div>
                          <div id="msg-generate-qrcode" class="msg">Ponovo generišite QR CODE </div>
                          <div class="pay-div" display="none"><button id="btnGenerateQR" class="pay-btn btn-black btn-hide" onclick="getQRCode()">GENERIŠI QR</button> </div>
                          <div class="cancel-div"><button  id="btnCancelQR"  type="button" class="pay-btn btn-grey btn-hide" id="cancel_btn">ODUSTANI</button></div>
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
