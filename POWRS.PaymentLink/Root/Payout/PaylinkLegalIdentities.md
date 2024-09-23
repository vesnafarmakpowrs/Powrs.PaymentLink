Title: Paylink Pending Legal Identities
Description: Displays Paylink pending legal identity applications.
Date: 2018-12-02
Author: Peter Waher
Master: /Master.md
Cache-Control: max-age=0, no-cache, no-store
CSS: ../EventLog.cssx
Javascript: ../Events.js
Javascript: PaylinkLegalIdentities.js
Script: ../Controls/SimpleTable.script
UserVariable: User
Privilege: Admin.Notarius.PendingIdentities
Login: ../Login.md

============================================================================================================================================

Pending Legal Identity Applications for Paylink
========================================

| Account | Created | 	 | First | Last |  Private | State |
|:--------|:----|:------|:------|:-------|:----|:------- |
{{
JoinOther(Properties[],Attachments[]):=
(
	First:=true;
	s:="";
	foreach Property in Properties do
	(	
		Name:= Property.Name;
		if(!Name.StartsWith("ORG")) then 
		(
			s+=MarkdownEncode(Property.Name)+"\\="+MarkdownEncode(Property.Value);
 			s+="</br>";	
		);
	);
	foreach Property in Properties do
	(	
		Name:= Property.Name;
		if(Name.StartsWith("ORG")) then 
		(
			s+=MarkdownEncode(Property.Name)+"\\="+MarkdownEncode(Property.Value);
 			s+="</br>";	
		);
	);

	if exists(Attachments) then
	(
		foreach Attachment in Attachments do
		(
			if exists(Attachment) then
			(
				if First then
					First:=false
				else
					s+="<br/>";
			
				s+="<a target=\"blank\" href=\"/Attachments/"+Attachment.Id+"\">"+Attachment.FileName+"</a>"
			)
		)
	);

	s
);

StateCreated:=IoTBroker.Legal.Identity.IdentityState.Created;
StateRejected:=IoTBroker.Legal.Identity.IdentityState.Rejected;
StateApproved:=IoTBroker.Legal.Identity.IdentityState.Approved;
StateObsoleted:=IoTBroker.Legal.Identity.IdentityState.Obsoleted;
StateCompromised:=IoTBroker.Legal.Identity.IdentityState.Compromised;

foreach Identity in 
select
	Id,
	Account, 
	State,
	Created.ToShortDateString() CreatedDate, 
	Created.ToLongTimeString() CreatedTime,
	this.FIRST FirstName,
	this.MIDDLE MiddleName,
	this.LAST LastName,
	this.Properties Properties,
	Attachments,
	this.AGENT Agent
from 
	IoTBroker.Legal.Identity.LegalIdentity
where
	State=IoTBroker.Legal.Identity.IdentityState.Created
order by
	Created desc
do
(
 if(!System.String.IsNullOrEmpty(Identity[10]) and Identity[10].Contains("VaulterApi/PaymentLink/Account/CreateAccount.ws")) then
(
	]]| ((MarkdownEncode(Identity[1]) )) | ((MarkdownEncode(Identity[3]) )) | ((MarkdownEncode(Identity[4]) )) | ((MarkdownEncode(Identity[5]) )) | ((MarkdownEncode(Identity[7]) )) | ((JoinOther(Identity[8],Identity[9]) )) | <select data-id="((Identity[0]))" data-prev="((State:=Identity[2]))" onchange="StateChanged(this)"><option value="Created"((State=StateCreated?" selected":""))>Created</option><option value="Rejected"((State=StateRejected?" selected":""))>Rejected</option><option value="Approved"((State=StateApproved?" selected":""))>Approved</option><option value="Obsoleted"((State=StateObsoleted?" selected":""))>Obsoleted</option><option value="Compromised"((State=StateCompromised?" selected":""))>Compromised</option></select> |
[[;
);
);
}}