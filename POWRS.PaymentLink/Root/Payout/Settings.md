Title: PaymentLink
Date: 2023-07-18
Author: Vesna Farmak
Description: Configures integration with the Open Payments Platform backend payment service.
Master: /Master.md
Cache-Control: max-age=0, no-cache, no-store
UserVariable: User
Privilege: Admin.Payments.Paiwise.OpenPaymentsPlatform
Login: /Login.md
JavaScript: Settings.js
JavaScript: /Sniffers/Sniffer.js


========================================================================

<form action="Settings.md" method="post" enctype="multipart/form-data">
<fieldset>
<legend>Payment Link settings</legend>

The following settings are required by the integration of the neuron with the Payment Link service backend. 
By providing such an integration, direct bank payments can be performed on the neuron, allowing end-users to buy and sell eDaler(R).


{{
if exists(Posted) then
(

	SetSetting("POWRS.PaymentLink.OPPUser",Posted.UserName);
	SetSetting("POWRS.PaymentLink.OPPUserPass",Posted.Password);
	

	SeeOther("Settings.md");
);
}}



<p>
<label for="ClientID">User Name:</label>  
<input type="text" id="UserName" name="UserName" value='{{GetSetting("POWRS.PaymentLink.OPPUser","")}}' autofocus required title="User Name ID identifying the OPP User in the Payment Link  backend."/>
</p>

<p>
<label for="Password">Secret:</label>  
<input type="password" id="Password" name="Password" value='{{GetSetting("POWRS.PaymentLink.OPPUserPass","")}}' required title="Password used to authenticate the OPP user with the backend."/>
</p>


<button type="submit" class="posButton">Apply</button>
</fieldset>

<fieldset>
<legend>Tools</legend>
</fieldset>
</form>
