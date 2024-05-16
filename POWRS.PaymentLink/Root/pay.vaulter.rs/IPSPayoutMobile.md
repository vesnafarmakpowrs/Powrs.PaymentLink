Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/IPS.cssx
CSS: css/BankList.css
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
JavaScript: js/Events.js
JavaScript: js/PaymentLink.js
JavaScript: js/BankList.js

<main class="main page-padding ips">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <div class="container">
       		<div class="content">  
                   <div class="article">
                        <div>
                             {{
   				 bankList := Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Models.GetBanks.Bank);
  			         bankList := POWRS.Payment.PaySpot.PayspotService.GetIndividualBankList();
				 ]]<label for="individualBanks">Platite mbanking aplikacijom svoje banke:</label> 
                                   <select name="individualBanks" id="individualBanks">[[;
                                   foreach bank in bankList do 
				    (
                                     ]]<option value="((bank.ID ))">((bank.Name ))</option>[[;
				    );   
                                   ]]</select> <br/>[[;
   				 bankLegalList := Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Models.GetBanks.Bank);
  			         bankLegalList := POWRS.Payment.PaySpot.PayspotService.GetLegalBankList();
				 ]]<br/>
                                   <label for="legalBanks">Platite mbanking aplikacijom za pravna lica ili preduzetnike:</label> 
                                   <select name="legalBanks" id="legalBanks">[[;
 				   foreach legalBank in bankLegalList do 
				    ( 
                                      ]]<option value="((legalBank.ID ))">((legalBank.Name ))</option>[[;
				    );     
   				  ]]</select> <br/><br/>
                                  <div class="dropdown">
                                    <div class="select-bank">-- select bank --</div>
                                       <div class="options">[[;
       					 foreach legalBank in bankLegalList do 
				         (   
                                            imageName :=  Before(legalBank.Name," ") != null ? Before(legalBank.Name," ") : legalBank.Name;
                                             Contains(legalBank.Name,"INTESA") ? imageName := "intesa";
                                             Contains(legalBank.Name,"POŠTANSKA") ? imageName := "pbs";
                                             imgSrc := "..\\resources\\personal_round\\"+ imageName + ".png";
                                           ]]<div class="bank-item" value="((legalBank.ID ))"><img class="bank-img" src="((imgSrc ))" alt=""/><label>((legalBank.Name ))</label></div>[[;
				         );
                                      ]] </div>
    				      </div>
				  </div>[[;                   
                             }}
                      </div>
          </div>
</main>
<div class="footer-parent">
  <div class="footer">
   Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - 2024 POWRS
  </div>
</div>
