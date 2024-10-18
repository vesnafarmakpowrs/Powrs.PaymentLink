
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateTranslations();
});

function GenerateTranslations() {
    var element = document.getElementById("SelectedAccountOk");
    if (element == null) {
        return;
    }

    Translations.SessionTokenExpiredMessage = document.getElementById("SessionTokenExpired").value;
}



function PaymentCompleted(Result) {
    location.reload();
}

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

function GenerateIPSPayment(bankID) {
       InitiatePaymentForm(true, FillAndSubmitPayspotIPSForm);
}

function InitiatePaymentForm(ipsOnly, onSuccess) {
    document.getElementById("payspot-submit").style.display = "none";
    document.getElementById("tr_spinner").style.display = null;
    CollapseDetails();

    SendXmlHttpRequest("../Payout/API/InitiatePayment.ws",
        {
            "isFromMobile": isMobileDevice,
            "tabId": TabID,
            "ipsOnly": true,
            "isCompany": false
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


  function infoPopup() { 
            const overlay = document.getElementById('popupOverlay'); 
            overlay.classList.toggle('show'); 
        } 

function SendXmlHttpRequest(resource, requestBody, onSuccess, onError) {
    let jwt = document.getElementById("jwt");
    if (!jwt.value.trim() === "") {
        alert("Session token not found, refresh the page and try again");
    }
    console.log(jwt.value);
    console.log(requestBody);
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", resource, true);
    xhttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.setRequestHeader("Authorization", "Bearer " + jwt.value);
    xhttp.send(JSON.stringify(requestBody));

    xhttp.onreadystatechange = function () {
        if (xhttp.readyState == 4) {
            if (xhttp.status == 200 && onSuccess != null) {
                let response = JSON.parse(xhttp.responseText);
                onSuccess(response);
            }
            else {
                if (xhttp.status == 403) {
                    alert(Translations.SessionTokenExpiredMessage);
                }
                else if (onError != null) {
                    onError(xhttp);
                }
            }
        };
    };
}

