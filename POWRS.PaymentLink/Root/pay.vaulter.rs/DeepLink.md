Title: Payment Link
Description: Displays information about a contract.
Date: 2023-08-04
Author: POWRS
Width: device-width
Cache-Control: max-age=0, no-cache, no-store
Pragma: no-cache
Expires: 0
Icon: favicon.ico
JavaScript: js/DeepLink.js
viewport : Width=device-width, initial-scale=1
Parameter: link

<main class="border-radius">
<meta name="viewport" content="width=device-width, initial-scale=1" />
<div class="container">
<div class="content">
{{
try
(
    if(exists(link) and !System.String.IsNullOrEmpty(link)) then 
    (
         ]]<input type='hidden' value='((link ))' id='deepLink'>[[;
    );
)
catch
(
    ]]<b>Payment link is not valid</b>[[;
  Return("");
);
}}