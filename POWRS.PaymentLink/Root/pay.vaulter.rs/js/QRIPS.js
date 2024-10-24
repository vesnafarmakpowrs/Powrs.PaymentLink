var timeoutHandle;
let start;

function countdown(minutes, seconds) {
    const totalTime = minutes * 60 + seconds;
    let elapsed = 0;
    function tick(timestamp) {
        if (!start) start = timestamp;
        elapsed = Math.floor((timestamp - start) / 1000);

        var counter = document.getElementById("timer");
        let remainingTime = totalTime - elapsed;

        if (remainingTime >= 0) {
            let minutesRemaining = Math.floor(remainingTime / 60);
            let secondsRemaining = remainingTime % 60;
            // Update the timer display
            var counter = document.getElementById("timer");
            counter.innerHTML = minutesRemaining.toString() + ":" + (secondsRemaining < 10 ? "0" : "") + secondsRemaining.toString();

            // Continue the countdown using requestAnimationFrame
            timeoutHandle = requestAnimationFrame(tick);
        }
        else {
            QRCodeExpire(true);
        }
    }
    requestAnimationFrame(tick);
}


function stopTimer() {
    if (typeof timeoutHandle !== 'undefined') {
        cancelAnimationFrame(timeoutHandle); // Stops the countdown
        QRCodeExpire(false);
    } else {
        console.log("No timer to stop.");
    }

}

function getQRCode() {
    QRCodeExpire(false);
    InitiateQRIPSPayment(GetQRCodeLinkSuccess);
}

function InitiateQRIPSPayment(onSuccess) {

    InitiateIPSPayment(0, false, false, onSuccess, QRTransactionFailed);
}

function QRTransactionFailed(Result) {
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

function QRCodeExpire(showTimeExpireTxt) {
    document.getElementById("QRCode").style.filter = "blur(3px)";
    document.getElementById("timer").innerHTML = "";
    if (showTimeExpireTxt == true) {
        document.getElementById("msg-time-expire").style.display = "block";
        document.getElementById("msg-generate-qrcode").style.display = "block";
    }
    else {
        document.getElementById("msg-time-expire").style.display = "none";
        document.getElementById("msg-generate-qrcode").style.display = "none";
    }

    ShowBtn(showTimeExpireTxt, document.getElementById("btnGenerateQR"));
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


function cancelTransaction()
{
    location.reload();
}