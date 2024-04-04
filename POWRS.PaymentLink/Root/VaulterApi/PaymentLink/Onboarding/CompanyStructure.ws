SessionUser:= Global.ValidateAgentApiToken(false, false);

({
   "FullNameAuthorizedRepresentative":Required(Str(PFullNameAuthorizedRepresentative)),
   "AuthorizedRepresentativeBirthDate":Required(Str(PAuthorizedRepresentativeBirthDate)),
   "OtherAuthorizedRepresentatives":Required(Str(POtherAuthorizedRepresentatives)),
   "PersonalDocumentNum":Required(Str(PPersonalDocumentNum)),
   "DocumentType":Required(Str(PDocumentType)),
   "CompanyBusinessCountry":Required(Str(PCompanyBusinessCountry)),
   "OwnerStrcture":Required(Str(POwnerStrcture)),
   "FunctionaStatusBeneficialOwner":Required(Str(PFunctionaStatusBeneficialOwner)),
   "OffShoreFondationTrast":Required(Str(POffShoreFondationTrast)),
   "DateOfIssuePersonalDocument":Required(Str(PDateOfIssuePersonalDocument)),
   "ForeignExchangeIdentificationNum":Required(Str(PForeignExchangeIdentificationNum)),
   "ForeignServiceUsersPercentage":Required(Int(PForeignServiceUsersPercentage)),
   "RealOwnersData":Required(Str(PRealOwnersData))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
 dict:= Create(System.Collections.Generic.Dictionary, System.String, System.Object);
 foreach(item in Posted) do ( dict.Add(item.Key, item.Value););
 newRecord:= false;

 data:= select top 1 * from POWRS.PaymentLink.Onboarding.CompanyStructure where UserName = SessionUser.username;
 if(data == null) then 
 (
    newRecord:= true;
	data := Create(POWRS.PaymentLink.Onboarding.CompanyStructure, SessionUser.username);
 );

 data.Fill(data, dict);

 if(newRecord) then 
 (
	Waher.Persistence.Database.Insert(data);
 )
 else
 (
	Waher.Persistence.Database.Update(data);
 );

 {
 }

)
catch
(
	Log.Error(Exception, "CompanyStructure", SessionUser.username, null);
	BadRequest(Exception.Message);
)