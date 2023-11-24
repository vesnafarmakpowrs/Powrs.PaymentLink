({
   "Namespace":Required(Str(PNamespace))	
}:=Posted) ??? BadRequest("Payload does not conform to specification.");

if(System.String.IsNullOrWhiteSpace(PNamespace)) then 
(
 BadRequest("Namespace is required");
);

response:= select l.Code, l.Name 
from LanguageNamespaces as ln 
join Languages as l on l.ObjectId = ln.LanguageId 
where ln.Name = PNamespace;

Return(response);