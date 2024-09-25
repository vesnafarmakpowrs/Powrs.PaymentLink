Title: Organization clients type
Description: Displays organization client types
Date: 2024-09-25
Author: Mirko Kruscic
Master: /Master.md
Cache-Control: max-age=0, no-cache, no-store
Javascript: OrganizationClientType.js
UserVariable: User
Login: ../Login.md

================================================================

Organization clinet type
========================================

<br />

| Organization | Client type |
|:-------------|:------------|
{{

organizationClientType := Select * from POWRS.PaymentLink.ClientType.Models.OrganizationClientType;

foreach item in organizationClientType ?? [] do
(
]]|((item.OrganizationName))|<select data-id="((item.ObjectId))" data-prev="((State:=item.OrgClientType.ToString()))" onchange="StateChanged(this)"><option value="Small"((State=Small?" selected":""))>Small</option><option value="Medium"((State=Medium?" selected":""))>Medium</option><option value="Large"((State=Large?" selected":""))>Large</option></select>|
[[;
)

}}
