var serviceProviders = null;
var selectedServiceProvider = null;

document.addEventListener("DOMContentLoaded", () => {
    GenerateServiceProvidersUI();
});

function ShowAccountInfo(Accounts) {
    if (Accounts.AccountInfo == null) {
        return;
    }

    GenerateAccountsListUi(Accounts.AccountInfo);
}

function GenerateServiceProvidersUI() {
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
                    let provider = serviceProviders.find(m => m.C1 == value);

                    if (provider == null) {
                        selectedServiceProvider = null;
                        alert("Select valid bank.");
                        return;
                    }

                    selectedServiceProvider = provider;
                    document.getElementById("QrCode").innerHTML = "";
                    GetAccountInfo();
                };
                for (let i = 0; i < serviceProviders.length; i++) {
                    const provider = serviceProviders[i];

                    var option = document.createElement("option");
                    option.text = provider.C1;

                    selectInput.add(option);
                }
            } else {
                alert('Unable to load service providers');
            }
        }
    }
}

function GenerateAccountsListUi(accounts) {
    console.log(accounts);
    const container = document.getElementById('QrCode');
    container.innerHTML = "";

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
            if (selectedServiceProvider == null) {
                return;
            }
            StartPayment(selectedServiceProvider.C5, account.Iban, account.Bic);
        }
        container.appendChild(bankElement);
    });
}

function StartPayment(BuyEdalerTemplateId, iban, bic) {
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

function DisplayTransactionResult(result) {
    console.log(result);
    var Div = document.getElementById("QrCode");
    Div.innerHTML = result.message;
}


function OpenUrl(Url) {
    var Window = window.open(Url, "_blank");
    Window.focus();
}

var isAndroid = false;
var isIOS = false;
var isChrome = false;
var isSafari = false;
var linkAlreadyOpened = false;
var paymentlinkAlreadyOpened = false;

function ShowQRCode(Data) {
    console.log(Data);
    var Div = document.getElementById("QrCode");

    var isAndroid = /Android/.test(navigator.userAgent);
    var isIOS = /(iPhone|iPad|iPod)/.test(navigator.platform);
    var isChrome = navigator.userAgentData?.brands?.some(b => b.brand === 'Google Chrome') || /CriOS/.test(navigator.userAgent);
    var isSafari = /safari/.test(window.navigator.userAgent.toLowerCase()) && !isChrome;

    var isPaymentInitialization = Data.isPaymentInitialization;
    var openedLinkAccInfo = linkAlreadyOpened && !isPaymentInitialization;
    var openedLinkPayment = paymentlinkAlreadyOpened && isPaymentInitialization;

    if (Data.fromMobileDevice && (!openedLinkAccInfo || !openedLinkPayment)) {
        var link = "bankid:///?autostarttoken=" + Data.AutoStartToken + "&redirect=null";
        if ((isIOS && isSafari) || (isChrome && isAndroid)) {
            link = "https://app.bankid.com/?autostarttoken=" + Data.AutoStartToken + "&redirect=null";
            window.open(link, "_self");
        }
        else
            window.open(link, "_blank");

        Div.innerHTML = "Opening authorization link: " + "<a href='" + link + "'></a>";
        window.open(link, "_self");
        if (Data.isPaymentInitialization)
            paymentlinkAlreadyOpened = true;
        else
            linkAlreadyOpened = true;
    }
    else if (Data.ImageUrl) {
        Div.innerHTML = "<fieldset><legend>" + Data.title + "</legend><p>" + Data.message +
            "</p><p><img class='QrCodeImage' alt='Bank ID QR Code' src='" + Data.ImageUrl + "'/></p></fieldset>";
    }
    else if (Data.AutoStartToken) {
        Div.innerHTML = "<fieldset><legend>" + Data.title + "</legend><p>" + Data.message +
            "</p><p>" + "<a href='" + Data.AutoStartToken + "'><img alt='Bank ID QR Code' src='/QR/" +
            encodeURIComponent(Data.AutoStartToken) + "'/></a></p></fieldset>";
    }
}

function PaymentError(Data) {
    var Div = document.getElementById("QrCode");
    Div.innerHTML = "<fieldset><legend>Error</legend><p>" + Data + "</p></fieldset>";
}