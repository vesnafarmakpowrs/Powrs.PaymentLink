
var Translations = {};


document.addEventListener("DOMContentLoaded", () => {
   GenerateTranslations();
});


function GenerateTranslations() {
    var element = document.getElementById("SelectedAccountOk");
    if (element == null) {
        return;
    }

    Translations.TransactionCompleted = document.getElementById("TransactionCompleted").value;
    Translations.TransactionFailed = document.getElementById("TransactionFailed").value;
    Translations.TransactionInProgress = document.getElementById("TransactionInProgress").value;
    Translations.SessionTokenExpiredMessage = document.getElementById("SessionTokenExpired").value;
}


function startTimer()
{

}

function getQRCode()
{
  InitiateIPSPayment(GetQRCodeLinkSuccess);
}


function InitiateIPSPayment(onSuccess) {
  
    SendXmlHttpRequest("../Payout/API/InitiateIPSPayment.ws",
        {
            "isFromMobile": false,
            "tabId": TabID,
            "ipsOnly": true,
            "bankId": 0           
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


function SendXmlHttpRequest(resource, requestBody, onSuccess, onError) {
     var jwt = parent.document.getElementById('jwt').value;
    
    if (!jwt.trim() === "") {
        alert("Session token not found, refresh the page and try again");
    }
    console.log(jwt);
    console.log(requestBody);
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", resource, true);
    xhttp.setRequestHeader("Content-Type", "application/json; charset=utf-8");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.setRequestHeader("Authorization", "Bearer " + jwt);
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


function GetQRCodeLinkSuccess(ResponseData) {

   console.log(ResponseData.Response);
   if (ResponseData.Response.QrCode != null) {
     document.getElementById("QRCode").src = ResponseData.Response.QrCode;
   }
    
}