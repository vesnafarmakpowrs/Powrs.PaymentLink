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
	SetSetting("POWRS.PaymentLink.KeyId",Posted.KeyId);
	SetSetting("POWRS.PaymentLink.Secret",Posted.Secret);
	
	SeeOther("Settings.md");
);
}}



<p>
<label for="ClientID">User Name:</label>  
<input type="text" id="UserName" name="UserName" value='{{GetSetting("POWRS.PaymentLink.OPPUser","")}}' autofocus required title="User Name ID identifying the OPP User in the Payment Link  backend."/>
</p>

<p>
<label for="Password">Password:</label>  
<input type="password" id="Password" name="Password" value='{{GetSetting("POWRS.PaymentLink.OPPUserPass","")}}' required title="Password used to authenticate the OPP user with the backend."/>
</p>

<p>
<label for="KeyId">Key Id:</label>  
<input type="text" id="KeyId" name="KeyId" value='{{GetSetting("POWRS.PaymentLink.KeyId","")}}' autofocus required title="Identity of key to use for signing the Identity application."/>
</p>

<p>
<label for="Secret">Secret:</label>  
<input type="password" id="Secret" name="Secret" value='{{GetSetting("POWRS.PaymentLink.Secret","")}}' required title="The secret corresponding to the key."/>
</p>

<button type="submit" class="posButton">Apply</button>
</fieldset>

<fieldset>
<legend>Tools</legend>
</fieldset>
</form>
