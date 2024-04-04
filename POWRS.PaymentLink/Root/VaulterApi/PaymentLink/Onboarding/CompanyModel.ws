SessionUser:= Global.ValidateAgentApiToken(false, false);

({
   "BusinessModel":Required(Str(PBusinessModel)),
   "ComplaintsPerMonth":Required(Int(PComplaintsPerMonth)),
   "ComplaintsPerYear":Required(Int(PComplaintsPerYear)),
   "DaysPaymentToDelivery":Required(Int(PDaysPaymentToDelivery)),
   "FullNameOwnerLargestShare":Required(Str(PFullNameOwnerLargestShare)),
   "PersonalNum":Required(Str(PPersonalNum)),
   "BirthDate":Required(Str(PBirthDate)),
   "BirthPlace":Required(Str(PBirthPlace)),
   "AddressAndPlaceOfResidence":Required(Str(PAddressAndPlaceOfResidence)),
   "DocumentNumber":Required(Str(PDocumentNumber)),
   "DocumentIssueDate":Required(Str(PDocumentIssueDate)),
   "DocumentIssueBy":Required(Str(PDocumentIssueBy)),
   "DocumentIssuePlace":Required(Str(PDocumentIssuePlace))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

try
(
 dict:= Create(System.Collections.Generic.Dictionary, System.String, System.Object);
 foreach(item in Posted) do ( dict.Add(item.Key, item.Value););
 newRecord:= false;

 data:= select top 1 * from POWRS.PaymentLink.Onboarding.CompanyModel where UserName = SessionUser.username;
 if(data == null) then 
 (
    newRecord:= true;
	data := Create(POWRS.PaymentLink.Onboarding.CompanyModel, SessionUser.username);
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
)
catch
(
	Log.Error(Exception, "CompanyModel", SessionUser.username, null);
	BadRequest(Exception.Message);
)