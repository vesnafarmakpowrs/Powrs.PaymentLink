({
	"tabId": Required(Str(PTabID)),
	"sessionId": Required(Str(PSessionId)),
	"requestFromMobilePhone": Required(Boolean(PRequestFromMobilePhone)),
	"qrCodeUsed": Required(Boolean(PQrCodeUsed)),
	"functionName": Required(Str(PFunctionName))
}:=Posted) ??? BadRequest("Payload does not conform to specification.");


OPPServiceProvider := TAG.Payments.OpenPaymentsPlatform.OpenPaymentsPlatformServiceProvider;
OPPServiceProvider.PushStatusChanges(PSessionId,PTabID,PFunctionName,RequestFromMobilePhone,PQrCodeUsed);