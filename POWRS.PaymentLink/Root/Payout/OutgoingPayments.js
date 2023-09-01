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
                    let provider = serviceProviders.find(m => m.C1 == value);

                    if (provider == null) {
                        selectedServiceProvider = null;
                        alert("Select valid bank.");
                        return;
                    }

                    selectedServiceProvider = provider;
                    ClearQrCodeDiv();
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

function ClearQrCodeDiv() {
    var container = document.getElementById('QrCode');
    container.innerHTML = "";
    ToggleSpinner(true);

    return container;
}

function GenerateAccountsListUi(accounts) {
    var container = ClearQrCodeDiv();

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
            StartPayment(selectedServiceProvider.C5, account.Iban, account.Bic);
        }
        container.appendChild(bankElement);
    });
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
            "bicFi": selectedServiceProvider.C2,
            "bankName": selectedServiceProvider.C1,
            "contractId": document.getElementById("contractId").value
        }));

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
    var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
    if (isSafari) {
        link = Data.MobileAppUrl;
        mode = "_self";
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