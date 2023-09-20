var updateTimer = null;

function OpenBankIDApp(AppUrl, SessionId, RequestFromMobilePhone, QrCodeUsed) {
    RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed);

    var Div = document.getElementById("TestStatus");

    Div.innerHTML = "in showQRCode" + encodeURIComponent(AppUrl);


    window.open(AppUrl, "_self");
}

function StartQrCodeAnimation(SessionId, RequestFromMobilePhone, QrCodeUsed) {
    RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed);
    updateTimer = window.setInterval(UpdateQrCode, 1000);
}


function RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "RegisterUpdates.ws", true);
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


function UpdateQrCode() {
    var Img = document.getElementById("AnimatedQrCode");
    if (!Img)
        return;

    var SessionId = Img.getAttribute("data-sessionId");

    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function () {
        if (xhttp.readyState === 4) {
            if (xhttp.status === 200) {
                var QrCode = JSON.parse(xhttp.responseText);
                Img.setAttribute("src", QrCode.imageUrl);

                var Loop = Img.nextSibling;
                while (Loop && Loop.tagName != "PRE")
                    Loop = Loop.nextSibling;

                if (Loop)
                    Loop.innerHTML = "<code>" + QrCode.url + "</code>";
            }
            else
                StopAnimation();
        }
    }

    xhttp.open("POST", "GetSessionUrl.ws", true);
    xhttp.setRequestHeader("Content-Type", "text/plain");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(SessionId);
}

function StopAnimation() {
    if (updateTimer) {
        window.clearInterval(updateTimer);
        updateTimer = null;

        var Img = document.getElementById("AnimatedQrCode");
        if (Img)
            Img.setAttribute("style", "display:none");
    }
}

function SessionUpdated(Data) {
    var SessionStatus = document.getElementById("SessionStatus");
    console.log(SessionStatus);
    console.log(Data);
    console.log(JSON.stringify(Data, null, 2));

    console.log(SessionStatus.innerText);
    SessionStatus.innerText = JSON.stringify(Data, null, 2);

    var Message = document.getElementById("Message");
    Message.innerText = Data.messageEnglish;

    switch (Data.status) {
        case "complete":
        case "failed":
            StopAnimation();
            break;
    }
}


function autoLaunchBankID(autostarttoken) {
    var custom = 'bankid:///?autostarttoken=' + autostarttoken + '&redirect=null',
        alt = 'alt.html',
        g_intent = 'intent://?autostarttoken=' + autostarttoken + '&redirect=null#Intent;scheme=bankid;package=com.bankid.bus;end',
        timer,
        heartbeat,
        iframe_timer;

    activate();

    function activate() {
        heartbeat = setInterval(intervalHeartbeat, 200);
        if (navigator.userAgent.match(/Chrome/)) {
            useIntent();
        } else if (navigator.userAgent.match(/Firefox/)) {
            tryWebkitApproach();
            iframe_timer = setTimeout(function () {
                tryIframeApproach();
            }, 1500);
        } else {
            tryIframeApproach();
        }
    }

    function clearTimers() {
        clearTimeout(timer);
        clearTimeout(heartbeat);
        clearTimeout(iframe_timer);
    }

    function intervalHeartbeat() {
        if (document.webkitHidden || document.hidden) {
            clearTimers();
        }
    }

    function tryIframeApproach() {
        var iframe = document.createElement("iframe");
        iframe.style.border = "none";
        iframe.style.width = "1px";
        iframe.style.height = "1px";
        iframe.onload = function () {
            window.location = alt;
        };
        iframe.src = custom;
        document.body.appendChild(iframe);
    }

    function tryWebkitApproach() {
        window.location = custom;
        timer = setTimeout(function () {
            window.location = alt;
        }, 2500);
    }

    function useIntent() {
        window.location = g_intent;
    }
}
function downloadPDF(base64Data, filename) {
    // Convert the base64 string to a Blob
    const byteCharacters = atob(base64Data);
    const byteArrays = [];
    for (let offset = 0; offset < byteCharacters.length; offset += 512) {
        const slice = byteCharacters.slice(offset, offset + 512);
        const byteNumbers = new Array(slice.length);
        for (let i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
    }
    const blob = new Blob(byteArrays, { type: 'application/pdf' });

    // Create an anchor link and trigger the download
    const link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(link.href); // clean up
}

function generatePDF() {
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "DealInfo.ws", true);
    xhttp.setRequestHeader("Content-Type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(JSON.stringify(
        {
            "contractId": document.getElementById("contractId").value,
            "countryCode": "EN"
        }));
    xhttp.onreadystatechange = function () {
        if (xhttp.readyState === 4) {
            if (xhttp.status === 200) {
                var response = JSON.parse(xhttp.responseText);
                downloadPDF(response.PDF, response.Name);
            }
        }
    }
}

