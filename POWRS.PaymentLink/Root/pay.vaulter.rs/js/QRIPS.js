
var Translations = {};
document.addEventListener("DOMContentLoaded", () => {
   GenerateTranslations();
});

var timeoutHandle;

function countdown(minutes, seconds) {
    function tick() {
        var counter = document.getElementById("timer");
        counter.innerHTML =
            minutes.toString() + ":" + (seconds < 10 ? "0" : "") + String(seconds);
        seconds--;
        if (seconds >= 0) {
            timeoutHandle = setTimeout(tick, 1000);
        } else {
            if (minutes >= 1) {
                setTimeout(function () {
                    countdown(minutes - 1, 59);
                }, 1000);
            }
           else {
            QRCodeExpire();
            }
        }
    }
    tick();
}


function GenerateTranslations() {
  
    Translations.TransactionCompleted = document.getElementById("TransactionCompleted").value;
    Translations.TransactionFailed = document.getElementById("TransactionFailed").value;
    Translations.TransactionInProgress = document.getElementById("TransactionInProgress").value;
    Translations.SessionTokenExpiredMessage = document.getElementById("SessionTokenExpired").value;
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
   if (ResponseData.Response.QrCode != null) 
     SetQRCode(ResponseData.Response.QrCode);    
}

function QRCodeExpire()
{

  document.getElementById("QRCode").style.filter = "blur(3px)";
  document.getElementById("timer").innerHTML = "";
  document.getElementById("msg-time-expire").style.display = "block";
  document.getElementById("msg-generate-qrcode").style.display = "block";
  
  ShowBtn(true, document.getElementById("btnGenerateQR"));
}

function SetQRCode(QRCode)
{
  document.getElementById("QRCode").src = QRCode;
  document.getElementById("QRCode").style.removeProperty("filter");
  
  countdown(1, 00);
  if (document.getElementById("msg-time-expire").getAttribute("style") != null )
       document.getElementById("msg-time-expire").removeAttribute("style");

  if (document.getElementById("msg-generate-qrcode").getAttribute("style") != null)
       document.getElementById("msg-generate-qrcode").removeAttribute("style");
  
  ShowBtn(false, document.getElementById("btnGenerateQR"));
  ShowBtn(true, document.getElementById("btnCancelQR"));
}

function ShowBtn(show, btn)
{
   if (show)
   { 
     if (btn.classList.contains("btn-hide")) 
        btn.classList.remove("btn-hide");
     btn.classList.add("btn-show");
   }
   else
   {
     if (btn.classList.contains("btn-show")) 
        btn.classList.remove("btn-show");
     btn.classList.add("btn-hide");
   }
}