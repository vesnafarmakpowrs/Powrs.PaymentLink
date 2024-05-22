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
JavaScript: js/IPSPayment.js

<main class="main page-padding ips">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
    <div class="container"> 
                   <div >
                          <div class="pay-div" ><label>Platite mbanking aplikacijom svoje banke</label></div>
                          <div class="pay-div" ><button class="pay-btn btn-black" onclick="getbanksIE()">Fizicka lica</button> </div>
                          <div class="pay-div" ><button class="pay-btn btn-grey" onclick="getbanksLE()">Pravna lica ili preduzetnike</button></div>
                 </div>
    </div>
    <input type="hidden" value="((JWT ))" id="jwt"/>
</main>
