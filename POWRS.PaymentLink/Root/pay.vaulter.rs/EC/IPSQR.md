Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../css/IPS.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
JavaScript: ../js/Events.js
JavaScript: ../js/XmlHttp.js
JavaScript: ../js/QRIPS.js


<main class="main page-padding ips">
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
     ]]<div class="container">
              <div class="content"> 
                   <div class="article">
                        <div class="div-logo-ips">
                            <img src=".././resources/ipslogo.png" alt="ipsLogoScan"/>
                            <img src=".././resources/vaulter_logo.webp" alt="VaulterLogo"/>
                        </div>    
                        <div><label>((LanguageNamespace.GetStringAsync(68) ))</label> </div>
                   </div> 
                   <div class="div-ips-code">
                      <div> 
                          <img id="QRCode" style="filter: blur(3px)" src="data:image/jpg;base64, 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" alt="">
                      </div>
                      <div class="qr-timer">
                          <strong><div class="pomView" timer id="timer"></div></strong>
              	      </div>   
                      <div class="gen-wrap">
                          <div id="msg-time-expire" class="msg">((LanguageNamespace.GetStringAsync(69) ))</div>
                          <div id="msg-generate-qrcode" class="msg">((LanguageNamespace.GetStringAsync(70) ))</div>
                          <div class="pay-div" display="none"><button id="btnGenerateQR" class="pay-btn btn-black btn-hide" onclick="getQRCode()">((LanguageNamespace.GetStringAsync(71) ))</button> </div>
                          <div class="cancel-div"> <button  id="btnCancelQR"  onclick="cancelTransaction()"  type="button" class="pay-btn btn-grey" id="cancel_btn">((LanguageNamespace.GetStringAsync(72) ))</button></div>
                      </div> 
                  </div>
                </div>           
        </div>
		
<input type="hidden" value="((lng ))" id="prefferedLanguage"/>
<input type="hidden" value="((PageToken ))" id="jwt"/>
<input type="hidden" value="POWRS.PaymentLink" id="Namespace"/>

<input type="hidden" value="((LanguageNamespace.GetStringAsync(27) ))" id="TransactionCompleted"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(28) ))" id="TransactionFailed"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(29) ))" id="TransactionInProgress"/>
<input type="hidden" value="((LanguageNamespace.GetStringAsync(47) ))" id="SessionTokenExpired"/>[[
}}
</main>
