Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: css/IPS.cssx
CSS: css/BankList.css
CSS: https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: TYPE
Parameter: JWT
JavaScript: js/Events.js
JavaScript: js/IPSPayment.js
JavaScript: js/BankList.js
JavaScript: https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.0/jquery.min.js
JavaScript: https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js
JavaScript: https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js
JavaScript: https://code.jquery.com/jquery-3.5.1.slim.min.js

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
           bankList := Create(System.Collections.Generic.List, POWRS.Networking.PaySpot.Models.GetBanks.Bank);
          if (TYPE == 'IE') then (
             bankList := POWRS.Payment.PaySpot.PayspotService.GetIndividualBankList();
           )
   	  else
           (
             bankList := POWRS.Payment.PaySpot.PayspotService.GetLegalBankList();
           );
           ]]<div class="dropdown"> 
              <input type="text" class="search-bank-box" id="searchBank" onkeyup="searchBank()" placeholder="Search for bank..">
              <ul id="bankList" class="bank-list-ul"> [[;
                  foreach bank in bankList do 
                    ( 
                       imageName :=  Before(bank.Name," ") != null ? Before(bank.Name," ") : bank.Name;
                       Contains(bank.Name,"INTESA") ? imageName := "intesa";
                       Contains(bank.Name,"POŠTANSKA") ? imageName := "pbs";
                       imgSrc := "..\\resources\\personal_round\\"+ imageName + ".png";
                       ]]<li class="dropdown-item" onClick="OpenDeepLink( ((bank.ID )) )"> <img src="(( imgSrc))" width="50px" height="100%">((bank.Name ))</li> [[;
                   );     
            ]]</ul>            
        </div> 
  <input type="hidden" value="((JWT ))" id="jwt"/>
  <input type="hidden" value="((LanguageNamespace.GetStringAsync(47) ))" id="SessionTokenExpired"/>[[;
}}
</main>