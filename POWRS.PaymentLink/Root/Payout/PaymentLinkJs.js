var serviceProviders = null;
var selectedServiceProvider = null;
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateServiceProvidersUI();
});

function ShowAccountInfo(Accounts) {
    if (Accounts.AccountInfo == null) {
        return;
    }

    GenerateAccountsListUi(Accounts.AccountInfo);
    ToggleSpinner(false);
}

function GenerateServiceProvidersUI() {
    if (document.getElementById("serviceProvidersSelect") == null) {
        return;
    }

    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "GetBuyEdalerServiceProviders.ws", true);
    xhttp.setRequestHeader("Content-Type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(JSON.stringify(
        {
            "Country": "SE",
            "Currency": "SEK"
        }));

    xhttp.onreadystatechange = function () {
        if (xhttp.readyState === 4) {
            var response = JSON.parse(xhttp.responseText);
            if (xhttp.status === 200) {
                serviceProviders = response.ServiceProviders;

                let selectInput = document.getElementById("serviceProvidersSelect");
                selectInput.innerHTML = "";

                let defaultOption = document.createElement("option");
                defaultOption.text = '-- Please select bank --';
                selectInput.add(defaultOption);

                selectInput.onchange = function () {
                    var value = document.getElementById("serviceProvidersSelect").value;
                    let provider = serviceProviders.find(m => m.Name == value);

                    if (provider == null) {
                        selectedServiceProvider = null;
                        alert("Select valid bank.");
                        return;
                    }
                    selectedServiceProvider = provider;
                    if (!Boolean(isMobileDevice) && !provider.QRCode) {
                        ShowMessage("To pay with this bank, please open the payment link from your phone.");
                    }
                    else {
                        ClearQrCodeDiv();
                        GetAccountInfo();
                    }
                };
                for (let i = 0; i < serviceProviders.length; i++) {
                    const provider = serviceProviders[i];
                    if (provider != null) {
                        var option = document.createElement("option");
                        option.text = provider.Name;
                        selectInput.add(option);
                    }
                }
            } else {
                alert('Unable to load service providers');
            }
        }
    }
}

function ClearQrCodeDiv() {
    var container = document.getElementById('QrCode');
    container.innerHTML = "";
    ToggleSpinner(true);

    return container;
}

function GenerateAccountsListUi(accounts) {
    var container = ClearQrCodeDiv();
    var accountList = document.createElement('div');
    accountList.className = "account-list";

    accounts.forEach(account => {
        const bankElement = document.createElement('button');
        bankElement.classList.add('account-item');
        bankElement.setAttribute('type', 'button');

        const logoElement = document.createElement('img');
        logoElement.src = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQce5OBW3Rp2nPNUDZ7WlyXSPx2VEW27rrHQ&usqp=CAU';
        logoElement.classList.add('account-logo');

        var nameAndBalance = document.createElement('div');
        nameAndBalance.classList.add('name-balance');

        const nameElement = document.createElement('div');
        nameElement.textContent = account.Name;
        nameElement.classList.add('account-name');

        const balanceElement = document.createElement('div');
        balanceElement.textContent = account.Balance + " " + account.Currency;
        balanceElement.classList.add('balance');

        nameAndBalance.appendChild(nameElement);
        nameAndBalance.appendChild(balanceElement);

        bankElement.appendChild(logoElement);
        bankElement.appendChild(nameAndBalance);
        bankElement.onclick = function () {
            var balance = parseFloat(account.Balance);
            if (!balance || balance <= 0) {
                alert("Unable to select " + account.Iban + ". Balance is not sufficient.");
                return;
            }
            if (selectedServiceProvider == null) {
                return;
            }
            if (!window.confirm("Selected account is: " + account.Iban + ". Are you sure?")) {
                return;
            }
            StartPayment(selectedServiceProvider.BuyEDalerTemplateContractId, account.Iban, account.Bic);
        }
        accountList.appendChild(bankElement);
    });

    container.appendChild(accountList);
}

function GetAccountInfo() {
    const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "GetAccountInfo.ws", true);
    xhttp.setRequestHeader("Content-Type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(JSON.stringify(
        {
            "tabId": TabID,
            "sessionId": "",
            "requestFromMobilePhone": Boolean(isMobileDevice),
            "bicFi": selectedServiceProvider.Id,
            "bankName": selectedServiceProvider.Name,
            "contractId": document.getElementById("contractId").value
        }));

    xhttp.onreadystatechange = function () {
        if (xhttp.readyState === 4 && xhttp.status === 200) {
            var response = JSON.parse(xhttp.responseText);
            if (isMobileDevice) {
                ShowAccountInfo(response.Results);
            }
        }
    }
}

function StartPayment(BuyEdalerTemplateId, iban, bic) {
    ToggleServiceProviderSelect(true);
    ClearQrCodeDiv();
    let contractId = document.getElementById('contractId').value;

    if (!contractId || !BuyEdalerTemplateId || !iban) {
        alert("Contract, template or account missing.");
        return;
    }

    const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");
    var xhttp = new XMLHttpRequest();
    xhttp.open("POST", "InitiatePayment.ws", true);
    xhttp.setRequestHeader("Content-Type", "application/json");
    xhttp.setRequestHeader("Accept", "application/json");
    xhttp.send(JSON.stringify(
        {
            "buyEdalerTemplateId": BuyEdalerTemplateId,
            "tabId": TabID,
            "requestFromMobilePhone": Boolean(isMobileDevice),
            "contractId": contractId,
            "bankAccount": iban,
            "bic": bic
        }));
}

function DisplayTransactionResult(Result) {
    var Div = ClearQrCodeDiv();
    Div.innerHTML = Result.Message;
    if (Result.IsCompleted) {
        ToggleSpinner(false);
        if (Result.IsSuccess) {
            setTimeout(function () {
                location.reload();
            }, 4000);
        }
    }
}


function OpenBankIdApp(Data) {
    if (Data == null) {
        console.log("data is empty");
        return;
    }

    var link = Data.BankIdUrl;
    var mode = "_blank";
    var isIos = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);

    if (isIos) {
        link = Data.MobileAppUrl;
        mode = "_self";
        let chromeAgent = navigator.userAgent.indexOf("Chrome") > -1;
        if (!chromeAgent) {
            link = link.replace('redirect=null', 'redirect=');
        }
    }
    window.open(link, mode);
}

function ToggleServiceProviderSelect(shouldBeDisabled) {
    var select = document.getElementById("serviceProvidersSelect");
    select.disabled = shouldBeDisabled;
}
function ToggleSpinner(showSpinner) {
    var spinner = document.getElementById("spinnerContainer");
    let displayStyle = showSpinner ? "flex" : "none";
    spinner.style.display = displayStyle;
}

function ShowMessage(message) {
    var Div = document.getElementById("QrCode");
    Div.innerHTML = "<fieldset><legend>Message</legend><p>" + message + "</p></fieldset>";
}

function ShowQRCode(Data) {
    var Div = document.getElementById("QrCode");

    if (Data.ImageUrl) {
        Div.innerHTML = "<fieldset><legend>" + Data.title + "</legend><p>" + Data.message +
            "</p><p><img class='QrCodeImage' alt='Bank ID QR Code' src='" + Data.ImageUrl + "'/></p></fieldset>";
    }
    else if (Data.AutoStartToken) {
        Div.innerHTML = "<fieldset><legend>" + Data.title + "</legend><p>" + Data.message +
            "</p><p>" + "<a href='" + Data.AutoStartToken + "'><img alt='Bank ID QR Code' src='/QR/" +
            encodeURIComponent(Data.AutoStartToken) + "'/></a></p></fieldset>";
    }

    ToggleSpinner(false);
}

function PaymentError(Data) {
    var Div = document.getElementById("QrCode");
    Div.innerHTML = "<fieldset><legend>Error</legend><p>" + Data + "</p></fieldset>";
}

function UserAgree() {
    if (!document.getElementById("purchaseAgreement").checked ||
        !document.getElementById("termsAndCondition").checked) {
        document.getElementById("serviceProvidersSelect").disabled = true;
    }
    else {
        document.getElementById("serviceProvidersSelect").disabled = false;
        var container = document.getElementById('QrCode');
        container.innerHTML = "";
    }
}

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