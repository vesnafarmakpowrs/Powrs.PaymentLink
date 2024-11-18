function getbanksIE() {
    var url = 'IPSBank.md';
    openBankListURL(url, "&TYPE=IE");
}

function getbanksLE() {

    var url = 'IPSBank.md';
    openBankListURL(url, "&TYPE=LE");
}

function openBankListURL(url, parameter) {
    var jwt = parent.document.getElementById('jwt').value;

    console.log(jwt);
    if (jwt == "") {
        alert("Session token not found, refresh the page and try again");
    }

    url = url + "&JWT=" + jwt.trim();
    window.parent.location.href = window.parent.location.href + parameter;
    console.log(window.parent.location.href);
    // window.open(url, '_PARENT');
}

function infoPopup() {
    const overlay = document.getElementById('popupOverlay');
    overlay.classList.toggle('show');
}
function OpenDeepLink(bankId) {
    DiasableItems(true);
    var type = parent.document.getElementById('type').value;
    let isCompany = type.toLowerCase().trim() == "le";
    console.log("type: " + type);
    if (type.toLowerCase().trim() == "le")
        isCompany = true;
    InitiateIPSPayment(bankId, true, isCompany, GetDeepLinkSuccess, IPSTransactionFailed);
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

function IPSTransactionFailed(Result) {
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
    let url = `${window.location.protocol}//${window.location.host}/DeepLink.md`;
    const params = new URLSearchParams(url.search);
    params.set('link', ResponseData.Response.DeepLink);
    url += "?" + params.toString();
    let mode = "_self";

    if (isIos) {
        mode = "_blank";      
    }

    window.open(url, mode);
    DiasableItems(false);
}
