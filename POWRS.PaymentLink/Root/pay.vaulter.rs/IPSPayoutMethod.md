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
    <div class="container">
                   <div >
                          <div class="pay-div pay-div-header" >
                             <label>Platite mbanking aplikacijom svoje banke</label>
			     <img src="resources\info.png" class="img-info" onclick="infoPopup()"/> 
                          </div>
                          <div class="pay-div" ><button class="pay-btn btn-black" onclick="getbanksIE()">Fizicka lica</button> </div>
                          <div class="pay-div" ><button class="pay-btn btn-grey" onclick="getbanksLE()">Pravna lica ili preduzetnike</button></div>
                 </div>
        <div id="popupOverlay" class="overlay-container"> 
        <div class="popup-box"> 
            <h2 style="color: green;"></h2> 
            <form class="form-container"> 
                <label class="form-label">Informacija o ishodu plaćanja biće Vam prikazana odmah po završetku obrade ali će Vam biti dostavljena i na e-mail adresu uz potvrdu o kupovini.</label> 
            </form> 
            <button class="btn-close-popup pay-btn btn-black" onclick="infoPopup()">Close</button> 
        </div> 
    </div> 
    </div>
    <input type="hidden" value="((JWT ))" id="jwt"/>
</main>
