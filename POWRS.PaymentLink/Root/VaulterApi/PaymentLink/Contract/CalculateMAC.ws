Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "OPERATION":Required(String(POPERATION)),
    "SHOPID":Required(String(PSHOPID)),
    "ORDERID":Required(String(PORDERID)),
	"PAN":Required(String(PPAN)),
	"CVV":Required(String(PCVV)),
    "EXPDATE":Required(String(PEXPDATE)),
    "AMOUNT":Required(String(PAMOUNT)),
    "CURRENCY":Optional(String(PCURRENCY)),
    "ACCOUNTINGMODE": Required(Str(PACCOUNTINGMODE)),
    "NETWORK": Optional(Str(PNETWORK)),
    "SECRETKEY" :  Optional(Str(PSECRETKEY))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
	rnd := Create(System.Random);
	RandomNum := rnd.Next(10000,999999);
	POPERATORID := PSHOPID;
	PREQREFNUM := Now.ToString("yyyyMMddHHmmssmmHHddMMyyyy") + RandomNum;
    PTIMESTAMP := Now.ToString("yyyy-MM-ddTHH:mm:ss.000");
	
PlainText := 'OPERATION=' + POPERATION + '&TIMESTAMP=' + PTIMESTAMP + '&SHOPID=' + PSHOPID + '&ORDERID=' + PORDERID + '&OPERATORID=' + POPERATORID + '&REQREFNUM=' + PREQREFNUM + 
'&PAN=' + PPAN + '&CVV2=' + PCVV + '&EXPDATE=' + PEXPDATE + '&AMOUNT=' + PAMOUNT + '&CURRENCY=' + PCURRENCY + '&EXPONENT=2&ACCOUNTINGMODE=' + PACCOUNTINGMODE + '&NETWORK=' + PNETWORK;

MAC := Sha2_256HMac(Utf8Encode(PlainText),Utf8Encode(PSECRETKEY));


AuthorizationData := "<?xml version='1.0' encoding='ISO-8859-1'?> "  ;
AuthorizationData +=  "<BPWXmlRequest> " ;
AuthorizationData += "    <Release>02</Release> ";
AuthorizationData +="    <Request>  ";
AuthorizationData +="        <Operation>"+ POPERATION +"</Operation>";
AuthorizationData +="        <Timestamp>"+ PTIMESTAMP +"</Timestamp>";
AuthorizationData +="        <MAC>" + HexEncode(MAC) + "</MAC>";
AuthorizationData +="    </Request>";
AuthorizationData +="    <Data>";
AuthorizationData +="        <AuthorizationRequest>";
AuthorizationData +="            <Header>";
AuthorizationData +="                <ShopID>"+ PSHOPID +"</ShopID>";
AuthorizationData +="                <OperatorID>" +  POPERATORID + "</OperatorID>";
AuthorizationData +="                <ReqRefNum>" + PREQREFNUM + "</ReqRefNum>";
AuthorizationData +="            </Header>";
AuthorizationData +="            <OrderID>" + PORDERID + "</OrderID>";
AuthorizationData +="            <Pan>" + PPAN  + "</Pan>";
AuthorizationData +="            <CVV2>" + PCVV + "</CVV2>";
AuthorizationData +="            <ExpDate>" + PEXPDATE +"</ExpDate>";
AuthorizationData +="            <Amount>" + PAMOUNT + "</Amount>";
AuthorizationData +="            <Currency>" + PCURRENCY +"</Currency>";
AuthorizationData +="            <Exponent>2</Exponent>";
AuthorizationData +="            <AccountingMode>"+ PACCOUNTINGMODE +"</AccountingMode>";
AuthorizationData +="            <Network>" + PNETWORK+ "</Network> ";
AuthorizationData +="        </AuthorizationRequest>";
AuthorizationData +="    </Data>";
AuthorizationData +="</BPWXmlRequest>";

PaySpotApiURL := "https://virtualpostest.sia.eu/vpos/apibo/apiBOXML-UTF8.app";
Data := Xml(AuthorizationData);

{
   "PlainText" : PlainText ,
   "MAC base64" : Base64Encode(MAC),
   "MAC HEX" : HexEncode(MAC),
   "AuthorizationData" : AuthorizationData
 
}

)
catch
(
	Log.Error(Exception, logObject, logActor, logEventID, null);
    BadRequest(Exception.Message);
);
