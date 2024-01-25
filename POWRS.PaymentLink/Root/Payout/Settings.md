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
	SetSetting("POWRS.PaymentLink.PayDomain",Posted.PayDomain);
	SetSetting("POWRS.PaymentLink.ContactEmail",Posted.ContactEmail);
	SetSetting("POWRS.PaymentLink.TemplateId",Posted.TemplateId);
	SetSetting("POWRS.PaymentLink.ApiKey",Posted.ApiKey);
	SetSetting("POWRS.PaymentLink.ApiKeySecret",Posted.ApiKeySecret);
	SetSetting("POWRS.PaymentLink.PayoutPageTokenDuration", Str(Posted.PayoutPageTokenDuration));
	SetSetting("POWRS.PaymentLink.SMSTextLocalKey", Str(Posted.SMSTextLocalKey));
	
	SeeOther("Settings.md");
);
}}

<p>
 <label for="PayDomain">Pay Domain:</label>  
<input type="text" id="PayDomain" name="PayDomain" value='{{GetSetting("POWRS.PaymentLink.PayDomain","")}}' autofocus required title="Domain where users can reach payment link."/>
</p>

<p>
<label for="ContactEmail">Contact Email:</label>  
<input type="text" id="ContactEmail" name="ContactEmail" value='{{GetSetting("POWRS.PaymentLink.ContactEmail","")}}' autofocus required title="Contact Email will be used to recive emails when user send contact data on a Paylink Generator Contact Us Screen "/>
</p>

<p>
<label for="TemplateId">Template ID:</label>  
<input type="text" id="TemplateId" name="TemplateId" value='{{GetSetting("POWRS.PaymentLink.TemplateId","")}}' autofocus required title="TemplateId used for creating contracts. "/>
</p>

<p>
<label for="ApiKey">ApiKey:</label>  
<input type="text" id="ApiKey" name="ApiKey" value='{{GetSetting("POWRS.PaymentLink.ApiKey","")}}' autofocus required title="ApiKey used to create legal identities"/>
</p>

<p>
<label for="ApiKeySecret">ApiKeySecret: </label>  
<input type="text" id="ApiKeySecret" name="ApiKeySecret" value='{{GetSetting("POWRS.PaymentLink.ApiKeySecret","")}}' autofocus required title="ApiKeySecret used in pair with api key to create legal identities. "/>
</p>

<p>
<label for="PayoutPageTokenDuration">Token duration: </label>  
<input type="number" min="5" max="15" id="PayoutPageTokenDuration" name="PayoutPageTokenDuration" value='{{GetSetting("POWRS.PaymentLink.PayoutPageTokenDuration","")}}' autofocus required title="Duration of jwt token for initiating payment on payout page. "/>
</p>

<p>
<label for="SMSTextLocalKey">SMS TextLocal Key: </label>  
<input type="text" id="SMSTextLocalKey" name="SMSTextLocalKey" value='{{GetSetting("POWRS.PaymentLink.SMSTextLocalKey","")}}' autofocus required title="Key for sending SMS"/>
</p>

<button type="submit" class="posButton">Apply</button>
</fieldset>

<fieldset>
<legend>Tools</legend>
</fieldset>
</form>
