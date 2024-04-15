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
 dict:= Create(System.Collections.Generic.Dictionary, System.String, System.Object);
 foreach(item in Posted) do ( dict.Add(item.Key, item.Value););
 newRecord:= false;

 companyInformation:= select top 1 * from POWRS.PaymentLink.Onboarding.GeneralCompanyInformation where UserName = SessionUser.username;
 if(companyInformation == null) then 
 (
    newRecord:= true;
	companyInformation := Create(POWRS.PaymentLink.Onboarding.BaseCompanyInformation, SessionUser.username);
 );

 companyInformation.Fill(companyInformation, dict);

 if(newRecord) then 
 (
	Waher.Persistence.Database.Insert(companyInformation);
 )
 else
 (
	Waher.Persistence.Database.Update(companyInformation);
 );

 {
 }

)
catch
(
	Log.Error(Exception, "CompanyInformation", SessionUser.username, null);
	BadRequest(Exception.Message);
);