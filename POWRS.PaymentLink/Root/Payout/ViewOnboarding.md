Title: View Onboarding
Description: On this page user can find the onboarding data.
Date: 2024-06-05
Author: Mirko Kruscic
Master: /Master.md
JavaScript: ViewOnboarding.js
Privilege: Admin.Onboarding.Modify
Login: /Login.md
UserVariable: User
Parameter: ObjectId

================================================================

Onboarding data
----------

<br />

{{

UserName := select top 1 UserName from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where ObjectId = ObjectId;
if(UserName == null) then
(
]]<div>
<span style="color: red;"><strong>Object Id not found...</strong></span>
</div>

[[;
)
else 
(
onBoardingData:= POWRS.PaymentLink.Onboarding.Onboarding.GetOnboardingData(UserName);

CanEditLabel(item):=
(
	if (item.CanEdit) then
		"<span >Yes</span>"
	else
		"<span id='lblCanEdit_" + item.ObjectId + "'>No</span>"
);

ShowBtnAllowEdit(item):=
(
	s := "";
	if (!item.CanEdit) then
	(
		legalIdentityId:= select top 1 Id from LegalIdentities where Account = item.UserName and State = "Approved" order by Created desc;
		if (System.String.IsNullOrWhiteSpace(legalIdentityId)) then
		(
			s += " <button id='btnAllowEdit_" + item.ObjectId + "' type='button' class='posButton' onclick=\"AllowEditOnboarding('" + item.ObjectId + "', '" +  + item.UserName + "')\" title='Allow user to edit onboarding data'>Allow edit</button>";
		);
	);
	s
);

ShowUploadedFileDownloadLink(orgShortName, fileName):=
(
	neuronDomain:= "https://" + Gateway.Domain;
	companyLink := neuronDomain + "/VaulterApi/PaymentLink/Onboarding/UploadedFiles/" + orgShortName + "/";
	s := "<a href=\"" + companyLink + fileName + "\">" + MarkdownEncode(fileName) + "</a>";
	s
);


]]<div>
<strong>User name:</strong> ((MarkdownEncode(onBoardingData.GeneralCompanyInformation.UserName) ))
<br />
<strong>Org Full Name:</strong> ((MarkdownEncode(onBoardingData.GeneralCompanyInformation.FullName) ))
<br />
<strong>Org Short Name:</strong> ((MarkdownEncode(onBoardingData.GeneralCompanyInformation.ShortName) ))
<br />
<strong>Org number (MB):</strong> ((MarkdownEncode(onBoardingData.GeneralCompanyInformation.OrganizationNumber) ))
<br />
<strong>Tax number:</strong> ((MarkdownEncode(onBoardingData.GeneralCompanyInformation.TaxNumber) ))
<br />
<strong>User can edit data:</strong> ((CanEditLabel(onBoardingData.GeneralCompanyInformation) ))
</div>

[[;

]]<div>
<br />
<strong>Legal representatives:</strong>
[[;
foreach item in onBoardingData.GeneralCompanyInformation.LegalRepresentatives ?? [] do
(
]]<div>
<strong>Full name: </strong> ((MarkdownEncode(item.FullName) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, item.StatementOfOfficialDocument) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, item.IdCard) )) 
</div>
<br />

[[;
);

]]</div>
[[;

]]<div>
<br />
<strong>Owners:</strong>
[[;
foreach item in onBoardingData.CompanyStructure.Owners ?? [] do
(
]]<div>
<strong>Full name: </strong> ((MarkdownEncode(item.FullName) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, item.StatementOfOfficialDocument) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, item.IdCard) )) 
</div>
<br />

[[;
);

]]</div>
[[;

]]<div>
<br />
<strong>Uploaded documents:</strong>
<br />
Business Cooperation Request EMI: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, onBoardingData.LegalDocuments.BusinessCooperationRequest) ))
<br />
Contract With EMI: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, onBoardingData.LegalDocuments.ContractWithEMI) ))
<br />
Contract With Vaulter: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, onBoardingData.LegalDocuments.ContractWithVaulter) ))
<br />
Promissory Note: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, onBoardingData.LegalDocuments.PromissoryNote) ))
<br />
Request For Promissory Notes Registration: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, onBoardingData.LegalDocuments.RequestForPromissoryNotesRegistration) ))
<br />
Card Of Deposited Signatures: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.OrganizationNumber, onBoardingData.LegalDocuments.CardOfDepositedSignatures) ))

<br /><br />
((ShowBtnAllowEdit(onBoardingData.GeneralCompanyInformation) ))
[[;

);
}}