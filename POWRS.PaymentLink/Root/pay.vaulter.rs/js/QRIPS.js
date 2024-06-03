
var Translations = {};
document.addEventListener("DOMContentLoaded", () => {
   getQRCode();
   GenerateQRTranslations();
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


function GenerateQRTranslations() {
  
    Translations.TransactionCompleted = document.getElementById("TransactionCompleted").value;
    Translations.TransactionFailed = document.getElementById("TransactionFailed").value;
    Translations.TransactionInProgress = document.getElementById("TransactionInProgress").value;
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
            "bankId": 0,
            "returnURL": null
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
  
  countdown(2, 00);
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

function PaymentCompleted(Result) {
    parent.location.reload();
}

function cancelTransaction()
{
     window.open("Redirect/Cancel.md", '_self');
}