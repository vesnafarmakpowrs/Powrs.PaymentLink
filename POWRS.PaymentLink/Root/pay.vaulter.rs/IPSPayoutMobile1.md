Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/IPS.cssx
CSS: https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
JavaScript: js/Events.js
JavaScript: js/PaymentLink.js
JavaScript: https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.0/jquery.min.js
JavaScript: https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js
JavaScript: https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js
JavaScript: https://code.jquery.com/jquery-3.5.1.slim.min.js

<main class="main page-padding ips">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
       {{
   	   bankList := Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Models.GetBanks.Bank);
  	   bankList := POWRS.Payment.PaySpot.PayspotService.GetIndividualBankList();
           ]]<div class="dropdown"> 
            <button class="btn btn-success  
                    dropdown-toggle" type="button" 
                    id="dropdownMenuButton" 
                    data-toggle="dropdown"
                    aria-haspopup="true" 
                    aria-expanded="false" style="width:100%"> 
                izaberi banka 
            </button> 
            <ul class="dropdown-menu" aria-labelledby="dropdownMenuButton"> [[;
                  foreach legalBank in bankList do 
                    ( 
                       imageName :=  Before(legalBank.Name," ") != null ? Before(legalBank.Name," ") : legalBank.Name;
                       Contains(legalBank.Name,"INTESA") ? imageName := "intesa";
                       Contains(legalBank.Name,"POŠTANSKA") ? imageName := "pbs";
                       imgSrc := "..\\resources\\personal_round\\"+ imageName + ".png";
                       ]]<li class="dropdown-item"> <img src= "(( imgSrc))"   width="50px" height="100%">((legalBank.Name ))</li> [[;
                   );     
           }} </ul> 
        </div> 
</main>
<div class="footer-parent">
  <div class="footer">
   Powrs D.O.O. Beograd, (org.no 21761818), Balkanska 2, Beograd <br/>Serbia ©2021 - 2024 POWRS
  </div>
</div>
