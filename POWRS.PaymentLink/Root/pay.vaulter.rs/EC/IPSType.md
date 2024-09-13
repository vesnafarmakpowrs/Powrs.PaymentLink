Title: IPS Payment
Description: Displays information about a contract.
Date: 2024-05-08
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
CSS: ../css/IPS.cssx
CSS: ../css/Info.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: ID
Parameter: lng
JavaScript: js/IPSType.js

<main class="main page-padding content-ips-method">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
{{
          
  	    Language:= null;
	    if (exists(lng)) then Language:= Translator.GetLanguageAsync(lng);
           
            if(Language == null) then 
            (
               lng:= "rs";
               Language:= Translator.GetLanguageAsync("rs");
             );

           Language:= Translator.GetLanguageAsync(lng);
           LanguageNamespace:= Language.GetNamespaceAsync("POWRS.PaymentLink");
    ]]<div class="container">
                   <div >
                          <div class="pay-div pay-div-header" >
                             <label>((LanguageNamespace.GetStringAsync(67) ))</label>
			     <img src="../resources/info.png" class="img-info" onclick="infoPopup()"/> 
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
    <input type="hidden" value="((PageToken ))" id="jwt"/>
    <input type="hidden" value="((TYPE ))" id="type"/>
	<input type="hidden" value="((ID ))" id="ID"/>
  <input type="hidden" value="((LanguageNamespace.GetStringAsync(47) ))" id="SessionTokenExpired"/>[[;
}}
</main>
