
function OpenDeepLink(bankId) {
    var type = parent.document.getElementById('type').value;
    let isCompany = type.toLowerCase().trim() == "le";
    InitiateIPSPayment(bankId, isCompany, GetDeepLinkSuccess);
}

function PaymentCompleted(Result) {
    if (Result != null && Result.successUrl != undefined && Result.successUrl.trim() != '') {
        setTimeout(function () {
            window.open(Result.successUrl, "_self");
        }, 1000);

        return;
    }
}

function InitiateIPSPayment(bankId, isCompany, onSuccess) {

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
        })
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

function GetDeepLinkSuccess(ResponseData) {

    var isIos = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
    var mode = "_blank";
    if (isIos) {
        mode = "_selft";
    }

    window.open(ResponseData.Response.DeepLink, mode);
}

function GetQRCodeLinkSuccess(ResponseData) {

    console.log(ResponseData.Response);
    console.log(ResponseData.Response.QrCode);
    document.getElementById("QRCode").src = ResponseData.Response.QrCode;

}