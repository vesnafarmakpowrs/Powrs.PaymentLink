
function OpenDeepLink(bankId) {
    DiasableItems(true);
    var type = parent.document.getElementById('type').value;
    let isCompany = type.toLowerCase().trim() == "le";
    console.log("type: " + type);
    if (type.toLowerCase().trim() == "le")
        isCompany = true;
    InitiateIPSPayment(bankId, isCompany, GetDeepLinkSuccess);
}

function PaymentCompleted(Result) {
    if (Result != null && Result.fallbackSuccessUrl != undefined && Result.fallbackSuccessUrl.trim() != '') {
        window.open(Result.fallbackSuccessUrl, "_self");
    }
}

function DiasableItems(disable) {
    banklist = document.getElementById("bankList");
    const items = banklist.getElementsByClassName("dropdown-item");

    for (item of items) {
        console.log(item);
        if (disable)
            item.classList.add("disabled");
        else
            item.classList.remove("disabled");
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
        mode = "_self";
    }

    window.open(ResponseData.Response.DeepLink, mode);
    DiasableItems(false);
}

function GetQRCodeLinkSuccess(ResponseData) {

    console.log(ResponseData.Response);
    console.log(ResponseData.Response.QrCode);
    document.getElementById("QRCode").src = ResponseData.Response.QrCode;

}