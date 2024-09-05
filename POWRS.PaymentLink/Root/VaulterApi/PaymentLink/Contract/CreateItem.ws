Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "orderNum":Required(String(PRemoteId)),
    "title":Required(String(PTitle)),
    "price":Required(Double(PPrice) >= 0.1),
    "currency":Required(String(PCurrency)),
    "description":Required(String(PDescription)),
    "paymentDeadline": Required(String(PPaymentDeadline)),
    "buyerFirstName":Required(String(PBuyerFirstName)),
    "buyerLastName":Required(String(PBuyerLastName)),
    "buyerEmail":Required(String(PBuyerEmail)),
    "buyerPhoneNumber":Optional(String(PBuyerPhoneNumber)),
    "buyerAddress": Required(Str(PBuyerAddress)) ,
    "buyerCountryCode":Required(String(PBuyerCountryCode)),
    "callbackUrl":Optional(String(PCallBackUrl)),
    "webPageUrl":Optional(String(PWebPageUrl))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
if(PRemoteId not like "^[\\p{L}\\s0-9-\/#-._]{1,50}$") then 
(
    Error("RemoteId not valid: " + PRemoteId);
);
if(PTitle not like "[\\p{L}\\s0-9.,;:!?()'\"\\/#_~+*@$%^& -]{2,30}") then
(
    Error("Title not valid: " + PTitle);
);
if(PCurrency not like "[A-Z]{3}") then 
(
    Error("Currency not valid: " + PCurrency);
);
if(PDescription not like "[\\p{L}\\s0-9.,;:!?()'\"\\/#_~+*@$%^& -]{5,100}") then
(
    Error("Description not valid: " + PDescription);
);
if(PPaymentDeadline not like "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$") then 
(
    Error("PaymentDeadline date format not valid: " + PPaymentDeadline);
);
if(PBuyerFirstName not like "[\\p{L}\\s\/,.&_-]{2,35}") then 
(
    Error("buyerFirstName not valid: " + PBuyerFirstName);
);

if(PBuyerLastName not like "[\\p{L}\\s\/,.&_-]{2,35}") then
(
    Error("buyerLastName not valid: " + PBuyerLastName);
);
if(PBuyerEmail not like "[\\p{L}\\d._%+-]+@[\\p{L}\\d.-]+\\.[\\p{L}]{2,50}") then 
(
    Error("BuyerEmail not valid: " + PBuyerEmail);
);
if(PBuyerPhoneNumber != null and PBuyerPhoneNumber not like "^[+]?[0-9]{6,15}$") then 
(
    Error("buyerPhoneNumber not valid: " + PBuyerPhoneNumber);
);
if(PBuyerAddress not like "^[\\p{L}\\p{N}\\s,./#-]{3,100}$") then 
(
    Error("buyerAddress not valid: " + PBuyerAddress);
);
if(PBuyerCountryCode not like "[A-Z]{2}") then 
(
    Error("BuyerCountry not valid: " + PBuyerCountryCode);
);

PPassword:= select top 1 Password from BrokerAccounts where UserName = SessionUser.username;
if(System.String.IsNullOrWhiteSpace(PPassword)) then 
(
    Error("No user with given username");
);

dateTemplate:= "dd/MM/yyyy HH:mm:ss";
PPaymentDeadline += " 23:59:59";
ParsedDeadlineDate:= System.DateTime.ParseExact(PPaymentDeadline, dateTemplate, System.Globalization.CultureInfo.CurrentUICulture).ToUniversalTime();
if(ParsedDeadlineDate < NowUtc) then 
(
    Error("Deadline must be in the future.");
);

KeyId := GetSetting(SessionUser.username + ".KeyId","");
KeyPassword:= GetSetting(SessionUser.username + ".KeySecret","");

if(System.String.IsNullOrEmpty(KeyId) or System.String.IsNullOrEmpty(KeyPassword)) then 
(
    Error("No signing keys or password available for user: " + SessionUser.username);
);

TemplateId:= GetSetting("POWRS.PaymentLink.TemplateId","");

if(System.String.IsNullOrWhiteSpace(TemplateId)) then 
(
    Error("Not configured correctly");
);

ContractParameters:= select top 1 Parameters from Contracts where ContractId = TemplateId;
if(ContractParameters == null) then 
(
 Error("Parameters for the contract does not exists.");
);

EscrowFee:= 0;
foreach Parameter in ContractParameters do 
(
  Parameter.Name like "EscrowFee" ?   EscrowFee := Parameter.ObjectValue;
);

  Identity := select top 1 * from IoTBroker.Legal.Identity.LegalIdentity where Account = SessionUser.username And State = 'Approved';

    AgentName := Identity.FIRST + " " + Identity.MIDDLE + " " + Identity.LAST;
    OrgName  := Identity.ORGNAME;
   
    if (System.String.IsNullOrEmpty(Identity.ORGBANKNUM)) then
       Error("Legal identity for this " + SessionUser.username + " mising bank account number");
    
    SellerBankAccount := Identity.ORGBANKNUM;
    SellerCountry := Identity.ORGCOUNTRY;
    SellerName:= !System.String.IsNullOrEmpty(OrgName) ? OrgName : AgentName;

    PSellerServiceProviderId := "";
    PSellerServiceProviderType := "";

BuyerPhoneNumber:= PBuyerPhoneNumber ?? "";
CallBackUrl:=  PCallBackUrl ?? "";
WebPageUrl:=  PWebPageUrl ?? "";

Contract:=CreateContract(SessionUser.username, TemplateId, "Public",
    {
        "RemoteId": PRemoteId,
	    "Title": PTitle,
        "Description": PDescription,
        "Value": PPrice,
        "PaymentDeadline" : ParsedDeadlineDate,
        "Currency": PCurrency,
        "Country": PBuyerCountryCode,
        "Expires": TodayUtc.AddDays(364),
        "SellerBankAccount" : SellerBankAccount,
        "SellerName" : SellerName,
        "SellerServiceProviderId" : PSellerServiceProviderId,
        "SellerServiceProviderType" : PSellerServiceProviderType,
        "BuyerFullName": PBuyerFirstName + " " + PBuyerLastName,
        "BuyerPhoneNumber": BuyerPhoneNumber,
        "BuyerEmail":PBuyerEmail,
        "CallBackUrl" : CallBackUrl,
        "WebPageUrl" : WebPageUrl,
        "SupportedPaymentMethods": "",
        "BuyerAddress": PBuyerAddress
    });

Nonce := Base64Encode(RandomBytes(32));

LocalName := "ed448";
Namespace := "urn:ieee:iot:e2e:1.0";

S1 := SessionUser.username + ":" + Waher.IoTGateway.Gateway.Domain + ":" + LocalName + ":" + Namespace + ":" + KeyId;
KeySignature := Base64Encode(Sha2_256HMac(Utf8Encode(S1),Utf8Encode(KeyPassword)));

ContractId := Contract.ContractId;
Role := "Creator";

S2 := S1 + ":" + KeySignature + ":" + Nonce + ":" + SessionUser.legalId + ":" + ContractId + ":" + Role;
RequestSignature := Base64Encode(Sha2_256HMac(Utf8Encode(S2),Utf8Encode(PPassword)));
NeuronAddress:= "https://" + Waher.IoTGateway.Gateway.Domain;
PaymentLinkAddress := "https://" + GetSetting("POWRS.PaymentLink.PayDomain","");
POST(NeuronAddress + "/Agent/Legal/SignContract",
                             {
	                        "keyId": KeyId,
	                        "legalId": SessionUser.legalId,
	                        "contractId": ContractId,
	                        "role": Role,
	                        "nonce": Nonce,
	                        "keySignature": KeySignature,
	                        "requestSignature": RequestSignature
                                },
			      {
			       "Accept" : "application/json",
			       "Authorization": "Bearer " + SessionUser.jwt
                              });

StateMachineInitialized:= false;
Counter:= 0;
TokenId := "";
while StateMachineInitialized == false and Counter < 10 do 
(
 Token:= select top 1 * from IoTBroker.NeuroFeatures.Token where OwnershipContract= Contract.ContractId;
 if(Token != null) then 
 (
    StateMachineInitialized:= Token.HasStateMachine;    
    TokenId := Token.TokenId;
 );
 Counter += 1;
 Sleep(1000);
);

Log.Informational("Succeffully cerated item.", logObject, logActor, logEventID, null);


{
    "Link" : PaymentLinkAddress + "/Payout.md?ID=" + Global.EncodeContractId(ContractId),
    "TokenId" : TokenId,
    "EscrowFee": EscrowFee,
    "BuyerEmail": PBuyerEmail,
    "BuyerPhoneNumber": BuyerPhoneNumber,
    "Currency": PCurrency
}

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
