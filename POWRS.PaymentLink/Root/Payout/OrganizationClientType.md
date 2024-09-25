Title: Organization clients type
Description: Displays organization client types
Date: 2024-09-25
Author: Mirko Kruscic
JavaScript: OrganizationClientType.js
Master: /Master.md
Cache-Control: max-age=0, no-cache, no-store
Privilege: Admin.Notarius.Identities
UserVariable: User
Login: ../Login.md

================================================================

Organization client type
========================================

<br />

| Organization | Client type |
|:-------------|:------------|
{{

organizationClientType := Select * from POWRS.PaymentLink.ClientType.Models.OrganizationClientType;

foreach item in organizationClientType ?? [] do
(
]]|((item.OrganizationName))| <select data-name="((MarkdownEncode(item.OrganizationName) ))" data-id="((item.ObjectId))" data-prev="((State:=item.OrgClientType.ToString() ))" onchange="ChangeClientType(this)"><option value="Small"((State="Small"?" selected":""))>Small</option><option value="Medium"((State="Medium"?" selected":""))>Medium</option><option value="Large"((State="Large"?" selected":""))>Large</option></select> |
[[;
);

}}