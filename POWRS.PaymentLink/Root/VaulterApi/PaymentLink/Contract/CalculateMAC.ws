Response.SetHeader("Access-Control-Allow-Origin","*");

if !exists(Posted) then BadRequest("No payload.");

({
    "OPERATION":Required(String(POPERATION)),
    "SHOPID":Required(String(PSHOPID)),
    "ORDERID":Required(String(PORDERID)),
    "EXPDATE":Required(String(PEXPDATE)),
    "AMOUNT":Required(String(PAMOUNT)),
    "CURRENCY":Optional(String(PCURRENCY)),
    "ACCOUNTINGMODE": Required(Str(PACCOUNTINGMODE)) ,
    "NETWORK": Optional(Str(PNETWORK)),
    "SECRETKEY" :  Optional(Str(PSECRETKEY))
}:=Posted) ??? BadRequest(Exception.Message);

SessionUser:= Global.ValidateAgentApiToken(true, true);

logObject := SessionUser.username;
logEventID := "CreateItem.ws";
logActor := Split(Request.RemoteEndPoint, ":")[0];

try
(
    RandomNum := "1496204690934584305834564";
	POPERATORID := PSHOPID;
	PREQREFNUM := Now.ToString("yyyyMMdd") + RandomNum;
    PTIMESTAMP := Now.ToString("yyyy-MM-ddTHH:mm:ss.000");
	PPAN := "4242424242424242";
	PCVV := "123";
	
PlainText := 'OPERATION=' + POPERATION + '&TIMESTAMP=' + PTIMESTAMP + '&SHOPID=' + PSHOPID + '&ORDERID=' + PSHOPID + '&OPERATORID=' + POPERATORID + '&REQREFNUM=' + PREQREFNUM + 
'&PAN=' + PPAN + '&CVV2=' + PCVV + '&EXPDATE=' + PEXPDATE + '&AMOUNT=' + PAMOUNT + '&CURRENCY=' + PCURRENCY + '&ACCOUNTINGMODE=' + PACCOUNTINGMODE + '&NETWORK=' + PNETWORK;

MAC := Sha2_256HMac(Utf8Encode(PlainText),Utf8Encode(PSECRETKEY));


AuthorizationData := "<?xml version='1.0' encoding='UTF-8'?> "  ;
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
AuthorizationData +="            <Network>" + +PNETWORK+ "</Network> ";
AuthorizationData +="        </AuthorizationRequest>";
AuthorizationData +="    </Data>";
AuthorizationData +="</BPWXmlRequest>";




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
