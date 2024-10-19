
function OpenDeepLink(bankId) {
    DiasableItems(true);
    var type = parent.document.getElementById('type').value;
    let isCompany = type.toLowerCase().trim() == "le";
    console.log("type: " + type);
    if (type.toLowerCase().trim() == "le")
        isCompany = true;
    InitiateIPSPayment(bankId, isCompany, GetDeepLinkSuccess);
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
    let url = ResponseData.Response.DeepLink;
    if (isIos) {
        url = `${window.location.protocol}//${window.location.host}/DeepLink.md`;
        const params = new URLSearchParams(url.search);
        params.set('link', ResponseData.Response.DeepLink);
        url += "?" + params.toString();
    }

    window.open(url, "_blank");
    DiasableItems(false);
}

function GetQRCodeLinkSuccess(ResponseData) {

    console.log(ResponseData.Response);
    console.log(ResponseData.Response.QrCode);
    document.getElementById("QRCode").src = ResponseData.Response.QrCode;

}