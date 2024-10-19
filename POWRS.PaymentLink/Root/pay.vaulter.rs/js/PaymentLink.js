
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateLanguageDropdown();
    GenerateTranslations();
});

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

    SendXmlHttpRequest("../Payout/API/GetAvailableLanguages.ws",
        {
            "Namespace": document.getElementById("Namespace").value
        }, (response) => {
            if (response != null && response.length > 0) {
                const languageDropdown = document.getElementById("languageDropdown");
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

function InitiatePaymentForm(onSuccess) {
    document.getElementById("payspot-submit").style.display = "none";
    document.getElementById("tr_spinner").style.display = null;
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

function HideSubmitPaymentDiv() {
    if (document.getElementById("submit-payment") != null)
        document.getElementById("submit-payment").style.display = "none";
}
function StartPayment() {
    HideSubmitPaymentDiv();
    InitiatePaymentForm(ShowPayspotPage);
}

function GenerateIPSForm() {
    HideSubmitPaymentDiv();
    InitiatePaymentForm(FillAndSubmitPayspotIPSForm);
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
        DisplayMessage(Translations.PaymentFailedWaitingRedirection, 'red');
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
        document.getElementById("tr_spinner").style.display = "none";
        document.getElementById("payspot_iframe").src = Data.Response;
        document.getElementById("payspot_iframe").style.display = null;
    }
}

function FillAndSubmitPayspotIPSForm(ResponseData) {
    if (ResponseData == null) {
        return;
    }
    if (ResponseData.Success) {
        let data = ResponseData.Response;
        // Fill the form fields with data from the API response
        document.querySelector('input[name="companyId"]').value = data.CompanyId;
        document.querySelector('input[name="merchantOrderID"]').value = data.MerchantOrderId;
        document.querySelector('input[name="merchantOrderAmount"]').value = data.MerchantOrderAmount;
        document.querySelector('input[name="merchantCurrencyCode"]').value = data.MerchantCurrencyCode;
        document.querySelector('input[name="language"]').value = data.Language;
        document.querySelector('input[name="callbackURL"]').value = data.CallbackURL;
        document.querySelector('input[name="successURL"]').value = data.SuccessURL;
        document.querySelector('input[name="cancelURL"]').value = data.CancelURL;
        document.querySelector('input[name="errorURL"]').value = data.ErrorURL;
        document.querySelector('input[name="hash"]').value = data.Hash;
        document.querySelector('input[name="rnd"]').value = data.Rnd;
        document.querySelector('input[name="currentDate"]').value = data.CurrentDate;

        var payspotForm = document.getElementById('payspotForm');

        payspotForm.action = data.SubmitAddress;
        payspotForm.submit();
    }
}