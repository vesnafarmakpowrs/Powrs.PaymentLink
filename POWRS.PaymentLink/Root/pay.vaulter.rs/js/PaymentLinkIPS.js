
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateLanguageDropdown();
    GenerateTranslations();

    var params = new URLSearchParams(window.location.search);
    var paymentResult = document.getElementById("PaymentResult").value.trim();
    
    if ((params.has('Retry') && params.get("Retry") === "true") || (paymentResult != "00" && paymentResult != "82" && paymentResult != "")) {
        showRetrydiv();
    }
    OnlyECommerce();
});


function OnlyECommerce() {
    var isEcommerce = (String(document.getElementById("IsEcommerce").value).toLowerCase() === 'true');

    if (isEcommerce)
        LoadIPS(1000);
}

function InitiateIPSPayment(bankId, isFromMobile, isCompany, onSuccess, onFailed) {
    SendXmlHttpRequest("../Payout/API/InitiateIPSPayment.ws",
        {
            "isFromMobile": isFromMobile,
            "tabId": TabID,
            "ipsOnly": true,
            "bankId": bankId,
            "isCompany": isCompany,
            "timeZoneOffset": new Date().getTimezoneOffset()
        },
        (response) => {
            onSuccess(response);
        },
        (error) => {
            if (error.status === 408) {
                return;
            }
            alert(error);
            onFailed(null);
        })
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
    Translations.TransactionCompleted = document.getElementById("TransactionCompleted").value;
    Translations.TransactionInProgress = document.getElementById("TransactionInProgress").value;
}

function GenerateLanguageDropdown() {
    var prefferedLanguage = document.getElementById("prefferedLanguage");
    if (prefferedLanguage == null) {
        return;
    }

    SendXmlHttpRequest("../Payout/API/GetAvailableLanguages.ws",
        {
            "Namespace": document.getElementById("Namespace").value
        }, (response) => {
            if (response != null && response.length > 0) {
                const languageDropdown = document.getElementById("languageDropdown");
                if (languageDropdown == null) {
                    return;
                }
                response.forEach(language => {
                    let option = document.createElement("option");
                    option.value = language.Code;
                    option.textContent = language.Name;
                    languageDropdown.appendChild(option);
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


function HideSubmitPaymentDiv() {
    if (document.getElementById("submit-payment") != null)
        document.getElementById("submit-payment").style.display = "none";
}


function LoadIPS(seconds) {
    console.log('loadIPS');
    HideSubmitPaymentDiv();

    setTimeout(function () {
        LoadIPSIiframe();
    }, seconds)

}

function LoadIPSIiframe() {
    if (isMobileDevice) {
        if (document.getElementById("ips-method") != null) {
            document.getElementById("ips-method").style.display = "block";
        }
    }
    else {

        if (document.getElementById("IPSScan") != null) {

            document.getElementById("IPSScan").style.display = "block";
            getQRCode();
        }

    }
}

var updateTimer = null;

function PaymentCompleted(Result) {
    DeleteUrlParam("TYPE");
    DeleteUrlParam("Retry");
}

function DeleteUrlParam(ParamName) {
    const url = new URL(window.location.href);
    url.searchParams.delete(ParamName);
    window.location.href = url.toString();
}

function BankListRedirect() {
    const url = new URL(window.location.href);
    const urlParams = new URLSearchParams(url.search);
    if (urlParams.has('TYPE')) {
        console.log('bank list');
        url.searchParams.delete("TYPE");
        window.location.href = url.toString() + "&Retry=true";
    }

}

function PaySpotPaymentStatus(Result) {

    BankListRedirect();
    if (Result != null && Result.StatusCode != null && Result.StatusCode == "82") {
        console.log(Result.Msg);
    }
    else if (Result != null && Result.StatusCode != null && (Result.StatusCode == "05" || Result.StatusCode == "-1")) {
        var element = document.getElementById('IPSScan');
        if (typeof (element) != 'undefined' && element != null) {
            document.getElementById('IPSScan').style.display = "none";
        }
        stopTimer();
        showRetrydiv();
    }
}

function showRetrydiv() {
    document.getElementById('submit-payment').style.display = "none";
    var div = document.getElementById('payment-msg-div');
    div.style.display = "block";
    var div = document.getElementById('payment-msg');
    div.innerHTML = '';
    var boldText = document.createElement('strong');
    boldText.textContent = Translations.PaymentFailed;;
    boldText.style.color = 'red';
    boldText.style.width = '70%';
    boldText.style.textAlign = 'center';
    div.appendChild(boldText);
    document.getElementById('retry-payment').style.display = "block";
}

function PaymentFailed() {

}

function RetryPayment() {
	
    document.getElementById('retry-payment').style.display = "none";
    var div = document.getElementById('payment-msg');
    div.innerHTML = '';
    document.getElementById('payment-msg-div').style.display = "none";
    document.getElementById('payment-msg-div').style.display = "none";
    LoadIPSIiframe();
}

