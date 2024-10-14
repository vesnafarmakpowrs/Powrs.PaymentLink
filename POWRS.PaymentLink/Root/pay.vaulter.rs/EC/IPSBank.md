Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../css/IPS.cssx
CSS: ../css/BankList.css
CSS: https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: TYPE
Parameter: ID
JavaScript: ../js/Events.js
JavaScript: ../js/BankList.js
JavaScript: ../js/XmlHttp.js

<main class="main page-padding content-bank">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
       {{
            ID:= Global.DecodeContractId(ID);
            Token:=select top 1 * from IoTBroker.NeuroFeatures.Token where OwnershipContract=ID;
	    if !exists(Token) then
            (
  		]]<b>Payment link is not valid</b>[[;
  		Return("");
             );  

	  if Token.HasStateMachine then
          (
            CurrentState:=Token.GetCurrentStateVariables();
            if exists(CurrentState) then
            ContractState:= CurrentState.State;
           );

          foreach Variable in (CurrentState.VariableValues ?? []) do 
          (        
            Variable.Name like "Country" ?   Country := MarkdownEncode(Variable.Value.ToString());
            Variable.Name like "Buyer" ?   BuyerFullName := MarkdownEncode(Variable.Value);
           );

            tokenDurationInMinutes:= Int(GetSetting("POWRS.PaymentLink.PayoutPageTokenDuration", 5));
        
              PageToken:= CreateJwt(
              {
                "iss":Gateway.Domain, 
                "contractId": ID,
                "tokenId": Token.TokenId,
                "sub": BuyerFullName, 
                "id": NewGuid().ToString(),
                "ip": Request.RemoteEndPoint,
                "country": Country,
                "ipsOnly": true,
                "exp": NowUtc.AddMinutes(tokenDurationInMinutes)
              });
             

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
              <label class="select-bank-lbl">Izaberi banka</label>
              <ul id="bankList" class="bank-list-ul"> [[;
                  foreach bank in bankList do 
                    ( 
                       bankName:= bank.Name;
                       imageName :=  Before(bank.Name," ") != null ? Before(bank.Name," ") : bank.Name;
                       Contains(bank.Name,"INTESA") ? imageName := "intesa";
                       Contains(bank.Name,"POŠTANSKA") ? imageName := "pbs";
                       Contains(bank.Name,"BANKA") ? bankName := Replace(bank.Name,"BANKA","");
                       bankName := TrimEnd(bankName);
                       bankName := TrimStart(bankName);
                       imgSrc := "..\\resources\\personal_round\\"+ imageName + ".jpg";
                       ]]<li class="dropdown-item" onClick="OpenDeepLink( ((bank.ID )),'((TYPE ))','((PageToken))' )"> <img src="(( imgSrc))" class="bank-img" />((bankName ))</li> [[;
                   );     
            ]]</ul>            
        </div> 
  <input type="hidden" value="((PageToken ))" id="jwt"/>
  <input type="hidden" value="((TYPE ))" id="type"/>
  <input type="hidden" value="((LanguageNamespace.GetStringAsync(47) ))" id="SessionTokenExpired"/>[[;
}}
</main>