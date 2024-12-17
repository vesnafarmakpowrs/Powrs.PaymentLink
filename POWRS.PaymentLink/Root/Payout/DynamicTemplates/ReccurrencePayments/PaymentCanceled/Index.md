Title: Payment Link
Description: Payment Link.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
Pragma: no-cache
Expires: 0
CSS: index.cssx
Icon: favicon.ico
viewport : Width=device-width, initial-scale=1
Parameter: TokenId

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container">
<div class="content">
{{
buyerName:= "Nenad Aleksic";
amount:= 10.00;
productName:= "Naknada za usluge";
currency:= "RSD";
maxFailedAttempts:= 5;
sellerName:= "Test firma";
sellerPhoneNumber:= "+381638818943";
sellerEmail:= "nenad.aleksic@powrs.se";

]]	 	<div class="header">
            <img src="data:image/png;base64,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" />
        </div>
        <div class="details">
            <div class="transaction-status">
                <h2>There was problem with your payment</h2>				
                <p>Something went wrong, and we were unable to process the charges on your CARDTYPE ending in PAN. Unfortunately, your ORGNAME subscription has been canceled </p>
                <br/>
				<p></p>
        </div>
			<div class="try-again">But don't worry, we understand that sometimes these things happen. You can always reactivate your ORGNAME subscription at any time. There's still so much to watch, and we're always adding more. Hope to see you back soon</div>
			<p></p> 
			<div class="update-div">
			   <a href="#" target="_blank" class="billing">Reactivate</a>
			</div>
			<p></p> 
			<p class="line"></p> 
        </div>
		 <div class="footer">
            <span class="footer-text"> POWRS D.O.O. BEOGRAD, Srbija</span>
            <span class="footer-text">©2021 - ((Now.Year )) POWRS</span>
            <span></span>
            <span style="text-align:left; margin-top:10px;" class="footer-text"> Saglasno odredbi člana 27. Zakona o zaštiti potrošača, možete popuniti <a href="https://pay.vaulter.rs/Obrazac-za-odustanak-od-ugovora.pdf ">obrazac za odustanak od ugovora</a></span>
        </div>
[[;
}}