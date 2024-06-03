Title: PLG Onboardings
Description: On this page user can find all onboardings.
Date: 2024-06-03
Author: Mirko Kruscic
Master: /Master.md
UserVariable: User
Privilege: Admin.Legal.ShowOnboardings
Login: /Login.md

================================================================

All Onboardings
----------

<br />

| UserName | Company short name | Org number (MB) | Tax number | Created | Can Edit | Options |
|:---------|:-------------------|:---------------:|:----------:|:--------|:--------:|:--------|
{{

CanEditLabel(item):=
(
	if item.CanEdit then
		"Yes"
	else 
		"No";
);

ShowButtonAllowEdit(item):=
(
	if !item.CanEdit then
		"<button type='button' class='posButton' onclick='ReturnToEdit()' title='Allow user to edit onboarding data'>Return to edit</button>"
	else 
		" ";
);

generalInfos:= select top 1000 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation;

foreach generalInfo in generalInfos ?? [] do
(
]]|((generalInfo.UserName))|((generalInfo.ShortName))|((generalInfo.OrganizationNumber))|((generalInfo.TaxNumber))|((generalInfo.Created))|((CanEditLabel(generalInfo) ))|((ShowButtonAllowEdit(generalInfo) ))|
[[;
)
}}