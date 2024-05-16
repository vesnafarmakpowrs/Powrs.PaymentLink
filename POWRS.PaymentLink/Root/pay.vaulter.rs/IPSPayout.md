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
JavaScript: js/PaymentLink.js

<main class="main page-padding ips">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
{{
    bankList := Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Models.GetBanks.Bank);
    bankList := POWRS.Payment.PaySpot.PayspotService.GetIndividualBankList();
  	]]<div class="container">
       		<div class="content">  
                   <div class="article">
                        <div>
                          <label for="bank">Choose bank:</label>
                             <select name="bank" id="bank">[[;
                               foreach (POWRS.Networking.PaySpot.Models.GetBanks.Bank bank in bankList) do
                                   ]]  ((bank.Name ))</option>[[;
			     ]] </select>
                        </div>
              		<div class="ips__logo-container">
               			<img src="./resources/ipslogo.png" alt="ipsLogoScan">
              			<svg width="121" height="45" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                  			<rect width="121" height="45" fill="url(#pattern0)"></rect>
                               </svg>
                        </div>
                        <p>Mbanking aplikacijom koju imate instaliranu na svom mobilnom uređaju skenirajte prikazani jednokratan IPS QR kod i izvršite plaćanje u okruženju Vaše banke. Informacija o ishodu plaćanja biće Vam prikazana odmah po završetku obrade ali će Vam biti dostavljena i na e-mail adresu uz potvrdu o kupovini.</p>
                   </div> 
                    <div class="form-wrapper">
              		<div class="qr-timer">
                        	<div class="pomView" data-testid="divTimer">
                        		<h1>1:29</h1>
                       		</div>
              		</div>     
	           </div>
                    <form action="#" class="form">
                      <div class="form__group"></div>
                      <div class="deeplink-wrap"></div>
                      <div class="form__button">
                       <div class="gen-wrap">
                          <span class="msg"> Vreme je isteklo<br>Ponovo generišite QR CODE </span>
                          <button type="button" class="btn btn__primary red" data-testid="submit-cancel-button">Odustani</button>
                  </div>
                </div>
              </form>
        </div>[[
}}
</main>
<div class="footer-parent">
  <div class="footer">
   Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - 2024 POWRS
  </div>
</div>
