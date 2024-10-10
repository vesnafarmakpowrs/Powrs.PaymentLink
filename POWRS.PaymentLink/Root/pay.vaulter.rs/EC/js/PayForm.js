
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

window.addEventListener("load", afterLoaded,false);
function afterLoaded(){
  GenerateTranslations();
  StartPayment();
}

function SendXmlHttpRequest(resource, requestBody, onSuccess, onError) {
    let jwt = document.getElementById("jwt");
    if (jwt == null && !jwt.value.trim() == "") {
        alert("Session token not found, refresh the page and try again");
    }

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


function LoadIPS()
{   
   console.log('loadIPS');
   document.getElementById("ips-iframe").src = "";
   if (isMobileDevice)
     document.getElementById("ips-iframe").src = "IPSPayoutMethod.md";
   else
   {
     document.getElementById("ips-iframe").src = "IPSDesktop.md";
     document.getElementById("ips-iframe").classList.remove("pay-iframe");
     document.getElementById("ips-iframe").classList.add("pay-iframe-web");
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
 
    document.getElementById("tr_spinner").style.display = null;
console.log(TabID);
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
function StartPayment() {
    InitiatePaymentForm(ShowPayspotPage);
}

function GenerateIPSForm() {
    InitiatePaymentForm(FillAndSubmitPayspotIPSForm);
}

function PaymentCompleted(Result) {
    location.reload();
}

function PaySpotPaymentStatus(Result) {

    if (Result != null && Result.StatusCode != null && Result.StatusCode != "00") {
        var div = document.getElementById('ctn-payment-method-rs');
        div.innerHTML = '';
        var boldText = document.createElement('strong');
        boldText.textContent = Translations.PaymentFailed;
        boldText.style.color = 'red';
        div.appendChild(boldText);
    }
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


function openWebURL(url) {
    window.open(url, '_blank');
}

function openBase64String(base64String) {
    var binaryString = window.atob(base64String);
    var bytes = new Uint8Array(binaryString.length);
    for (var i = 0; i < binaryString.length; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }

    // Create a Blob from the Uint8Array
    var blob = new Blob([bytes], { type: 'application/pdf' });

    // Create a temporary URL for the Blob
    var blobURL = URL.createObjectURL(blob);

    // Open a new window with the Blob URL
    var newWindow = window.open(blobURL);
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