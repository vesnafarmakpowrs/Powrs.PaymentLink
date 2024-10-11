

function OpenDeepLink(bankId,type, jwt)
{
   isCompany = type.toLowerCase().trim() == "le";
   InitiateIPSPayment(bankId, isCompany, GetDeepLinkSuccess, jwt);
}

function InitiateIPSPayment(bankId,  isCompany, onSuccess, jwt) {
console.log("jwt: " + jwt); 
    SendXmlHttpRequest("../Payout/API/InitiateIPSPayment.ws",
        {
            "isFromMobile": true,
            "tabId": TabID,
            "ipsOnly": true,
            "bankId": bankId,
            "isCompany": isCompany
        },
        (response) => {
            onSuccess(response);
        },
        (error) => {
            if (error.status === 408) {
                return;
            }
            alert(error);
            TransactionFailed(null);
        },jwt)
}

function TransactionFailed(Result) {
    let res = {
        IsCompleted: true,
        IsSuccess: false,
        Message: Translations.TransactionFailed
    };

    DisplayTransactionResult(res);
}

function DisplayTransactionResult(Result) {
    if (Result.IsCompleted) {
        if (Result.IsSuccess) {
            setTimeout(function () {
                location.reload();
            }, 4000);
        }
    }
}

function PaymentCompleted(Result) {
    if (Result != null && Result.fallbackSuccessUrl != undefined && Result.fallbackSuccessUrl.trim() != '') {
        window.open(Result.fallbackSuccessUrl, "_self");
    }
}

function GetDeepLinkSuccess(ResponseData) {
    var isIos = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
    var mode = "_blank";
    if (isIos) {
        mode = "_self";
    }

    window.open(ResponseData.Response.DeepLink, mode);
}

function GetQRCodeLinkSuccess(ResponseData) {

   console.log(ResponseData.Response);
   console.log(ResponseData.Response.QrCode);
   document.getElementById("QRCode").src = ResponseData.Response.QrCode;
    
}