
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    setTimeout(function () {
        GenerateLanguageDropdown();
        GenerateTranslations();
    }, 1000);

    OnlyECommerce();
});


function OnlyECommerce() {

    var isEcommerce = (String(document.getElementById("IsEcommerce").value).toLowerCase() === 'true');
    var isAwaitingForPayment = (String(document.getElementById("ContractState").value).toLowerCase() === 'awaitingforpayment')

    if (isAwaitingForPayment) {
        setTimeout(function () {
            InitiatePaymentForm(ShowPayspotPage);
        }, 1000);
    }
}

function GenerateTranslations() {
    var element = document.getElementById("SelectedAccountOk");
    if (element == null) {
        return;
    }

    Translations.SelectedAccountOk = document.getElementById("SelectedAccountOk").value;
    Translations.SelectedAccountNotOk = document.getElementById("SelectedAccountNotOk").value;
    Translations.QrCodeScanMessage = document.getElementById("QrCodeScanMessage").value;
    Translations.QrCodeScanTitle = document.getElementById("QrCodeScanTitle").value;
    Translations.TransactionCompleted = document.getElementById("TransactionCompleted").value;
    Translations.TransactionFailed = document.getElementById("TransactionFailed").value;
    Translations.TransactionInProgress = document.getElementById("TransactionInProgress").value;
    Translations.OpenLinkOnPhoneMessage = document.getElementById("OpenLinkOnPhoneMessage").value;
    Translations.SessionTokenExpiredMessage = document.getElementById("SessionTokenExpired").value;
    Translations.PaymentFailed = document.getElementById("PaymentFailed").value;
    Translations.PaymentCompletedWaitingRedirection = document.getElementById("PaymentCompletedWaitingRedirection").value;
    Translations.PaymentFailedWaitingRedirection = document.getElementById("PaymentCompletedWaitingRedirection").value;
}

function GenerateLanguageDropdown() {
    var prefferedLanguage = document.getElementById("prefferedLanguage");
    if (prefferedLanguage == null) {
        return;
    }

    const languageDropdown = document.getElementById("languageDropdown");
    if (languageDropdown == null) {
        return;
    }

    SendXmlHttpRequest("../Payout/API/GetAvailableLanguages.ws",
        {
            "Namespace": document.getElementById("Namespace").value
        }, (response) => {
            if (response != null && response.length > 0) {

                response.forEach(language => {
                    if (language.Code != 'sv') {
                        let option = document.createElement("option");
                        option.value = language.Code;
                        option.textContent = language.Name;
                        languageDropdown.appendChild(option);
                    }
                });

                languageDropdown.value = prefferedLanguage.value;
                languageDropdown.addEventListener("change", function (e) {
                    PreferredLanguage = languageDropdown.value;
                    let url = new URL(window.location.href);
                    url.searchParams.set('lng', languageDropdown.value);
                    window.location.href = url.toString();
                });
            }
        }, (error) => {
            console.log(error.responseText);
        });
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

var updateTimer = null;

function RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "../Payout/API/RegisterUpdates.ws", true);
    xhttp.setRequestHeader("Content-Type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(JSON.stringify(
        {
            "tabId": TabID,
            "sessionId": SessionId,
            "requestFromMobilePhone": RequestFromMobilePhone,
            "qrCodeUsed": QrCodeUsed,
            "functionName": "SessionUpdated"
        }));
}

function InitiatePaymentForm(onSuccess) {

    ShowHideElement("payspot-submit", "none");
    ShowHideElement("tr_spinner", null);
    CollapseDetails();

    SendXmlHttpRequest("../Payout/API/InitiatePayment.ws",
        {
            "isFromMobile": isMobileDevice,
            "tabId": TabID
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

function ShowHideElement(id, display) {
    if (document.getElementById(id) != null)
        document.getElementById(id).style.display = display;
}

function AddEventListener(elementId, eventName, Event) {
    if (document.getElementById(elementId) != null)
        document.getElementById(elementId).addEventListener(eventName, Event);
}

function HideSubmitPaymentDiv() {
    if (document.getElementById("submit-payment") != null)
        document.getElementById("submit-payment").style.display = "none";
}
function StartPayment() {
    HideSubmitPaymentDiv();
    InitiatePaymentForm(ShowPayspotPage);
}

function PaymentCompleted(Result) {
    if (Result != null && Result.successUrl != undefined && Result.successUrl.trim() != '') {
        DisplayMessage(Translations.PaymentCompletedWaitingRedirection, 'green');
        setTimeout(function () {
            window.open(Result.successUrl, "_self");
        }, 3000);

        return;
    }

    location.reload();
}

function PaySpotPaymentStatus(Result) {
    if (Result == null || Result.StatusCode == null || Result.StatusCode == "00") {
        return;
    }

    if (Result.ErrorUrl !== undefined && Result.ErrorUrl.trim() != '') {
        DisplayMessage(Translations.PaymentFailedWaitingRedirection, 'green');
        setTimeout(function () {
            window.open(Result.ErrorUrl, "_self");
        }, 3000);
        return;
    }

    DisplayMessage(Translations.PaymentFailed, 'red');
}

function DisplayMessage(message, color) {
    var div = document.getElementById('ctn-payment-method-rs');
    div.innerHTML = '';
    var boldText = document.createElement('strong');
    boldText.textContent = message;
    boldText.style.color = color;
    div.appendChild(boldText);
}

function ShowPayspotPage(Data) {
    if (Data == null) {
        console.log("data is empty");
        alert("Unrecognized response");
        return;
    }

    if (!Data.Success) {
        alert("Unrecognized response");
        console.log(Data);
    }

    if (isMobileDevice) {
        window.open(Data.Response, '_self').focus();
    }
    else {
        ShowHideElement("tr_spinner", "none");
        if (document.getElementById("payspot_iframe") != null)
            document.getElementById("payspot_iframe").src = Data.Response;
        ShowHideElement("payspot_iframe", null);
    }
}
