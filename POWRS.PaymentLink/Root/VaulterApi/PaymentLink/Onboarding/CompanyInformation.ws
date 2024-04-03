SessionUser:= Global.ValidateAgentApiToken(false, false);

({
   "ApplicantName":Required(String(PApplicantName)),
   "CompanyAddress":Required(String(PCompanyAddress)),
   "CompanyCity":Required(String(PCompanyCity)),
   "OrganizationNumber":Required(String(POrganizationNumber)),
   "TaxNumber":Required(String(PTaxNumber)),
   "ActivityNumber":Required(String(PActivityNumber)),
   "OtherCompanyActivities":Required(String(POtherCompanyActivities)),
   "BankName":Required(String(PBankName)),
   "BankAccountNumber":Required(String(PBankAccountNumber)),
   "StampUsage":Required(String(PStampUsage)),
   "TaxLiability":Required(String(PTaxLiability)),
   "OnboardingPurpose":Required(String(POnboardingPurpose)),
   "CompanyBussinesArea":Required(String(PCompanyBussinesArea)),
   "CompanyWebsite":Required(String(PCompanyWebsite)),
   "CompanyWebshop":Required(String(PCompanyWebshop))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try 
(
 companyInformation:= select top 1 * from POWRS.PaymentLink.Onboarding.BaseCompanyInformation where UserName = SessionUser.username;
 if(companyInformation == null) then 
 (
	instance := POWRS.PaymentLink.Onboarding.BaseCompanyInformation.CreateInstance(Posted);
	instance.UserName:= SessionUser.username;
	Waher.Persistence.Database.Insert(instance);
 )
 else 
 (
	instance := POWRS.PaymentLink.Onboarding.BaseCompanyInformation.CreateInstance(companyInformation, Posted);
	Waher.Persistence.Database.Update(instance);
 );
)
catch
(
	Log.Error(Exception, "CompanyInformation", SessionUser.username, null);
	BadRequest(Exception.Message);
);