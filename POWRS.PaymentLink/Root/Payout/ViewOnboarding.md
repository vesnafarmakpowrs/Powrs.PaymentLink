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
</div>

[[;

]]<div>
<br />
<strong>Legal representatives:</strong>
[[;
foreach item in onBoardingData.GeneralCompanyInformation.LegalRepresentatives ?? [] do
(
]]<div>
<strong>Full name: </strong> ((MarkdownEncode(item.FullName) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, item.StatementOfOfficialDocument) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, item.IdCard) )) 
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
<strong>Full name: </strong> ((MarkdownEncode(item.FullName) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, item.StatementOfOfficialDocument) )), <br />((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, item.IdCard) )) 
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
Business Cooperation Request EMI: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, onBoardingData.LegalDocuments.BusinessCooperationRequest) ))
<br />
Contract With EMI: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, onBoardingData.LegalDocuments.ContractWithEMI) ))
<br />
Promissory Note: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, onBoardingData.LegalDocuments.PromissoryNote) ))
<br />
Contract With Vaulter: ((ShowUploadedFileDownloadLink(onBoardingData.GeneralCompanyInformation.ShortName, onBoardingData.LegalDocuments.ContractWithVaulter) ))

[[;

);
}}