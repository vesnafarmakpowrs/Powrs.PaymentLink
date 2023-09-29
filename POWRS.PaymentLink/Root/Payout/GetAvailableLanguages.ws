({
   "Namespace":Required(Str(PNamespace))	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

if(System.String.IsNullOrWhiteSpace(PNamespace)) then 
(
 BadRequest("Namespace is required");
);

AvailableLanguageIds:= select LanguageId from LanguageNamespaces where Name = PNamespace;
AvailableLanguages:= Create(System.Collections.Generic.List, System.Object);
if(AvailableLanguageIds.Length > 0) then 
(
  FOR EACH Id in AvailableLanguageIds DO AvailableLanguages.Add(select top 1 * from Languages where ObjectId = Id);
);

{
  Languages: AvailableLanguages
}