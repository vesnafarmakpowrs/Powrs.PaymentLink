
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateLanguageDropdown();
    GenerateTranslations();
});

function InitiateIPSPayment(bankId, isFromMobile, isCompany, onSuccess) {
    SendXmlHttpRequest("../Payout/API/InitiateIPSPayment.ws",
        {
            "isFromMobile": isFromMobile,
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

function TransactionFailed(Result) {
    let res = {
        IsCompleted: true,
        IsSuccess: false,
        Message: Translations.TransactionFailed
    };
    document.getElementById("ctn-payment-method-rs").style.display = "block";
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

function HideSubmitPaymentDiv() {
    if (document.getElementById("submit-payment") != null)
        document.getElementById("submit-payment").style.display = "none";
}


function LoadIPS() {
    console.log('loadIPS');
	HideSubmitPaymentDiv();
	LoadIPSIiframe();
}

function LoadIPSIiframe()
{
    if (isMobileDevice)
        document.getElementById("ips-method").style.display = "block";
    else 
	{
		document.getElementById("IPSScan").style.display = "block";
	    getQRCode();
    }
}

var updateTimer = null;

function PaymentCompleted(Result) {
    const url = new URL(window.location.href);
    url.searchParams.delete("TYPE");
    window.location.href = url.toString();
}

function PaySpotPaymentStatus(Result) {
    if (Result != null && Result.StatusCode != null && Result.StatusCode == "82") {
        console.log(Result.Msg);
    }
    else if (Result != null && Result.StatusCode != null && (Result.StatusCode == "05" || Result.StatusCode == "-1")) {
        document.getElementById('ctn-payment-method-rs').style.display = "none";
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
}

function PaymentFailed(){
	
}	

function RetryPayment() {
	
    document.getElementById('retry-payment').style.display = "none";
    var div = document.getElementById('payment-msg');
    div.innerHTML = '';
	document.getElementById('payment-msg-div').style.display = "none";
    document.getElementById('payment-msg-div').style.display = "none";
    LoadIPSIiframe();
}

