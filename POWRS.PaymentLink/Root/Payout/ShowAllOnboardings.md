Title: PLG Onboardings
Description: On this page user can find all onboardings.
Date: 2024-06-03
Author: Mirko Kruscic
Master: /Master.md
JavaScript: ShowAllOnboardings.js
Privilege: Admin.Onboarding.Modify
Login: /Login.md
UserVariable: User

================================================================

All Onboardings
========================================

<br />

| UserName | Company short name | Org number (MB) | Tax number | Created | User can edit | Options |
|:---------|:-------------------|:---------------:|:----------:|:--------|:-------------:|:--------|
{{

CanEditLabel(item):=
(
	if (item.CanEdit) then
		"<span >Yes</span>"
	else
		"<span id='lblCanEdit_" + item.ObjectId + "'>No</span>"
);

ShowOptions(item):=
(
	s := "<button id='btnView_" + item.ObjectId + "' type='button' class='posButtonSm' onclick=\"ViewOnboarding('" + item.ObjectId + "', '" +  + item.UserName + "')\" title='View onboarding data'>View</button>";

	if (!item.CanEdit) then
	(
		legalIdentityId:= select top 1 Id from LegalIdentities where Account = item.UserName and State = "Approved" order by Created desc;
		if (System.String.IsNullOrWhiteSpace(legalIdentityId)) then
		(
			s += " <button id='btnAllowEdit_" + item.ObjectId + "' type='button' class='posButtonSm' onclick=\"AllowEditOnboarding('" + item.ObjectId + "', '" +  + item.UserName + "')\" title='Allow user to edit onboarding data'>Allow edit</button>";
		);
	);

	s
);

generalInfos:= select * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation;

foreach generalInfo in generalInfos ?? [] do
(
]]|((generalInfo.UserName))|((generalInfo.ShortName))|((generalInfo.OrganizationNumber))|((generalInfo.TaxNumber))|((generalInfo.Created))|((CanEditLabel(generalInfo) ))|((ShowOptions(generalInfo) ))|
[[;
)
}}