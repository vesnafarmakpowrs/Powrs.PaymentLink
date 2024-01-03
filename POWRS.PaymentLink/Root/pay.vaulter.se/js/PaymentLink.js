var serviceProviders = null;
var selectedServiceProvider = null;
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateLanguageDropdown();
    GenerateTranslations();
    GenerateServiceProvidersUI();
});

function SendXmlHttpRequest(resource, requestBody, onSuccess, onError) {
    let jwt = document.getElementById("jwt");
    if (!jwt.value.trim() === "") {
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
    Translations.EnterPersonalNumber = document.getElementById("EnterPersonalNumber").value;
    Translations.PersonalNumberInvalid = document.getElementById("PersonalNumberInvalid").value;
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
                response.forEach(language => {
                    let option = document.createElement("option");
                    option.value = language.Code;
                    option.textContent = language.Code;
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

    SendXmlHttpRequest("../Payout/API/GetBuyEdalerServiceProviders.ws",
        {},
        (response) => {
            serviceProviders = response.ServiceProviders;
            let selectInput = document.getElementById("serviceProvidersSelect");

            selectInput.onchange = function () {
                StartBankPayment();
                var value = document.getElementById("serviceProvidersSelect").value;
                let provider = serviceProviders.find(m => m.Name == value);

                if (provider == null) {
                    selectedServiceProvider = null;
                    alert("Select valid bank.");
                    return;
                }
                selectedServiceProvider = provider;
                if (!Boolean(isMobileDevice) && !provider.QRCode) {
                    ShowMessage(Translations.OpenLinkOnPhoneMessage);
                }
                else {
                    ClearQrCodeDiv();
                    if (provider.Name.includes('Stripe')) {
                        StartCardPayment();
                        return;
                    }
                    GenerateSSNUI();
                    // GetBankAccounts();
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
        }, null);
}


function ClearQrCodeDiv() {
    var container = document.getElementById('QrCode');
    container.innerHTML = "";

    return container;
}

function ClearSSNUI() {
    document.getElementById('payment-ssn-txt-td').innerHTML = "";
    document.getElementById('payment-ssn-btn-td').innerHTML = "";
    document.getElementById('payment-ssn-td').innerHTML = "";
    document.getElementById('payment-ssn-txt-tr').style.display = "none";
    document.getElementById('payment-ssn-tr').style.display = "none";
    document.getElementById('payment-ssn-btn-tr').style.display = "none";
}

function GenerateSSNUI() {
    document.getElementById('payment-ssn-txt-tr').style.display = null;
    var container_txt = document.getElementById('payment-ssn-txt-td');
    const ssn_txt = document.createElement('label');
    ssn_txt.classList.add('ssn-txt');
    ssn_txt.innerHTML = Translations.EnterPersonalNumber;
    ssn_txt.setAttribute('id', 'prn_txt');
    container_txt.innerHTML = "";
    container_txt.appendChild(ssn_txt);

    document.getElementById('payment-ssn-tr').style.display = null;
    var container_input = document.getElementById('payment-ssn-td');
    const ssn_input = document.createElement('input');
    ssn_input.classList.add('ssn-input');
    ssn_input.setAttribute('type', 'text');
    ssn_input.setAttribute('name', 'prn');
    ssn_input.setAttribute('id', 'ssn_input');

    const ssn_error_msg = document.createElement('input');
    ssn_input.classList.add('ssn-input');
    ssn_input.setAttribute('type', 'text');
    ssn_input.setAttribute('name', 'prn');
    ssn_input.setAttribute('id', 'ssn_input');

    const ssn_msg_p = document.createElement("p");
    const ssn_msg = document.createTextNode(Translations.PersonalNumberInvalid);
    ssn_msg_p.appendChild(ssn_msg);
    ssn_msg_p.setAttribute('id', 'ssn_invalid_msg');
    ssn_msg_p.style.color = "red";
    ssn_msg_p.style.display = "none";

    container_input.innerHTML = "";
    container_input.appendChild(ssn_input);
    container_input.appendChild(ssn_msg_p);

    document.getElementById('payment-ssn-btn-tr').style.display = null;
    var container_btn = document.getElementById('payment-ssn-btn-td');
    const ssn_button = document.createElement('button');
    ssn_button.classList.add('ssn-button');
    ssn_button.setAttribute('title', 'Continue');
    ssn_button.setAttribute('type', 'button');
    ssn_button.textContent = 'Continue';
    ssn_button.addEventListener("click", SubmitSSN);
    container_btn.innerHTML = "";
    container_btn.appendChild(ssn_button);
}

function SubmitSSN() {
    var ssn = document.getElementById('ssn_input').value;
    var ssn_invalid_msg = document.getElementById('ssn_invalid_msg');

    if (isSwedishSocialSecurityNumber(ssn)) {
        ClearSSNUI();
        GetBankAccounts();
        document.getElementById('PersonalNumber').value = ssn;
    }
    else {
        ssn_invalid_msg.style.display = "block";
        ssn_input.style.borderColor = "red";
    }
}

function isSwedishSocialSecurityNumber(ssn) {
    return /^(\d{6}|\d{8})[-|(\s)]{0,1}\d{4}$/.test(ssn);
}

function GenerateAccountsListUi(accounts) {
    var container = ClearQrCodeDiv();
    ToggleSpinner(true);
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
                alert(Translations.SelectedAccountNotOk);
                return;
            }
            if (selectedServiceProvider == null) {
                return;
            }

            if (!window.confirm(Translations.SelectedAccountOk.replace("{0}", account.Iban))) {
                return;
            }
            StartPayment(account.Iban, account.Bic);
        }
        accountList.appendChild(bankElement);
    });

    container.appendChild(accountList);
}

function GetBankAccounts() {

    SendXmlHttpRequest("../Payout/API/GetBankAccounts.ws", {
        "tabId": TabID,
        "sessionId": "",
        "requestFromMobilePhone": Boolean(isMobileDevice),
        "bicFi": selectedServiceProvider.Id,
        "bankName": selectedServiceProvider.Name
    }, (response) => {
        if (isMobileDevice) {
            ShowAccountInfo(response.Results);
        }
    }, null);
}

const isValidSwedishPersonalNumber = (personalNumber) => {
    const swedishPersonalNumberRegex = /^(19|20)?[0-9]{6}[-+]{0,1}[0-9]{4}$/;
    return swedishPersonalNumberRegex.test(personalNumber);
};

function StartPayment(iban, bic) {
    var personalNumber = document.getElementById('PersonalNumber').value;

    ToggleServiceProviderSelect(true);
    ClearQrCodeDiv();
    ToggleSpinner(true);

    if (!iban || !bic) {
        alert("Template or account missing.");
        return;
    }

    SendXmlHttpRequest("../Payout/API/InitiatePayment.ws", {
        "tabId": TabID,
        "requestFromMobilePhone": Boolean(isMobileDevice),
        "bankAccount": iban,
        "bic": bic,
        "personalNumber": personalNumber
    },
        (response) => {
            if (!response.OK) {
                TransactionFailed(null);
            }
        },
        (error) => {
            if (error.status === 408) {
                return;
            }
            TransactionFailed(null);
        });
}

function TransactionInProgress(Result) {
    let res = {
        IsCompleted: false,
        IsSuccess: false,
        Message: Translations.TransactionInProgress
    };

    DisplayTransactionResult(res);
}
function TransactionFailed(Result) {
    let res = {
        IsCompleted: true,
        IsSuccess: false,
        Message: Translations.TransactionFailed
    };

    DisplayTransactionResult(res);
}
function TransactionCompleted(Result) {
    let res = {
        IsCompleted: true,
        IsSuccess: true,
        Message: Translations.TransactionCompleted
    };

    DisplayTransactionResult(res);
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
        Div.innerHTML = "<fieldset><legend>" + Translations.QrCodeScanTitle + "</legend><p>" + Translations.QrCodeScanMessage +
            "</p><p><img class='QrCodeImage' alt='Bank ID QR Code' src='" + Data.ImageUrl + "'/></p></fieldset>";
    }
    else if (Data.AutoStartToken) {
        Div.innerHTML = "<fieldset><legend>" + Translations.QrCodeScanTitle + "</legend><p>" + Translations.QrCodeScanMessage +
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

    var Country = document.getElementById("country").value

    if (Country == "RS" && document.getElementById("termsAndCondition").checked) {
        document.getElementById("payspot-submit").removeAttribute("disabled");
        document.getElementById("left-to-pay").style.display = "block";
        document.getElementById("ctn-payment-method-rs").style.display = "block";
    }
    else if (Country == "RS" && !document.getElementById("termsAndCondition").checked) {
        document.getElementById("payspot-submit").setAttribute("disabled", "disabled");
        document.getElementById("left-to-pay").style.display = "none";
        document.getElementById("ctn-payment-method-rs").style.display = "none";
    }
    else {
        if (!document.getElementById("purchaseAgreement").checked ||
            !document.getElementById("termsAndCondition").checked) {
            document.getElementById("payment-form-bank").disabled = true;
            document.getElementById("payment-form-card").disabled = true;
        }
        else {
            document.getElementById("payment-form-bank").disabled = false;
            document.getElementById("payment-form-card").disabled = false;
            var container = document.getElementById('QrCode');
            container.innerHTML = "";
        }
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
    SendXmlHttpRequest("../Payout/API/DealInfo.ws",
        {},
        (response) => {
            downloadPDF(response.PDF, response.Name);
        }, null);
}

function AddStipeNameInput() {
    var t = document.getElementById("payment-element");

    var outerDiv = document.createElement('div');
    outerDiv.className = 'flex-item width-12 stipe-name-div';

    outerDiv.setAttribute('style', 'line-height:20px');
    // Create the FormFieldGroup div
    var formFieldGroupDiv = document.createElement('div');
    formFieldGroupDiv.className = 'FormFieldGroup';

    // Create the label and its container
    var labelContainer = document.createElement('div');
    labelContainer.className = 'stripe-cardholder-name FormFieldGroup-labelContainer flex-container justify-content-space-between';
    var label = document.createElement('label');
    label.setAttribute('for', 'billingName');
    label.setAttribute('style', 'align-self:flex-end');
    var labelText = document.createElement('span');
    labelText.className = 'Label Text-color--gray600 stipe-name-input';

    const cardHolderTxt = document.getElementById("cardHolderTxt");
    const cardHolderNameTxt = document.getElementById("cardHolderNameTxt");

    labelText.textContent = cardHolderTxt.value;
    label.appendChild(labelText);
    labelContainer.appendChild(label);

    // Create the Fieldset div with an inner container
    var fieldsetDiv = document.createElement('div');
    fieldsetDiv.className = 'FormFieldGroup-Fieldset';
    fieldsetDiv.id = 'billingName-fieldset';
    var fieldsetInnerDiv = document.createElement('div');
    fieldsetInnerDiv.className = 'FormFieldGroup-container';
    fieldsetInnerDiv.id = 'billingName-fieldset-inner';

    // Create the FormFieldGroup-child div
    var formFieldChildDiv = document.createElement('div');
    formFieldChildDiv.className = 'FormFieldGroup-child FormFieldGroup-child--width-12 FormFieldGroup-childLeft FormFieldGroup-childRight FormFieldGroup-childTop FormFieldGroup-childBottom';

    // Create the FormFieldInput div
    var formFieldInputDiv = document.createElement('div');
    formFieldInputDiv.className = 'p-FieldLabel';
    fieldsetDiv.setAttribute('style', 'vertical-align:bottom');
    // Create the CheckoutInputContainer div and its contents
    var checkoutInputContainerDiv = document.createElement('div');
    checkoutInputContainerDiv.className = 'CheckoutInputContainer';
    var inputContainerSpan = document.createElement('span');
    inputContainerSpan.className = 'InputContainer';
    inputContainerSpan.setAttribute('data-max', '');

    // Create the input element
    var inputElement = document.createElement('input');
    inputElement.className = 'CheckoutInput Input Input--empty';
    inputElement.setAttribute('autocomplete', 'ccname');
    inputElement.setAttribute('autocorrect', 'off');
    inputElement.setAttribute('spellcheck', 'false');
    inputElement.id = 'billingName';
    inputElement.name = 'billingName';
    inputElement.type = 'text';
    inputElement.setAttribute('placeholder', cardHolderNameTxt.value);
    inputElement.setAttribute('aria-invalid', 'false');
    inputElement.value = '';

    // Append the input element to the input container
    inputContainerSpan.appendChild(inputElement);

    // Append all elements together to create the desired structure
    checkoutInputContainerDiv.appendChild(inputContainerSpan);
    formFieldInputDiv.appendChild(checkoutInputContainerDiv);
    formFieldChildDiv.appendChild(formFieldInputDiv);
    fieldsetInnerDiv.appendChild(formFieldChildDiv);
    fieldsetDiv.appendChild(fieldsetInnerDiv);
    formFieldGroupDiv.appendChild(labelContainer);
    formFieldGroupDiv.appendChild(fieldsetDiv);
    outerDiv.appendChild(formFieldGroupDiv);

    t.appendChild(outerDiv);
}

function GeneratePaymentForm(Data) {
    var stripe = Stripe(Data.PublishableKey);
    const clientSecret = Data.ClientSecret;

    const appearance = {
        theme: 'stripe',
        variables: { colorPrimaryText: '#262626' }
    };

    const elements = stripe.elements({ appearance, clientSecret });

    const languageDropdown = document.getElementById("languageDropdown");
    elements.update({ locale: languageDropdown.value });

    const paymentElement = elements.create('payment');
    document.getElementById("stripe-submit").style.display = "block";
    // Add an instance of the card Element into the card-element div.
    paymentElement.mount('#payment-element');


    const form = document.getElementById('payment-form-card');
    AddStipeNameInput();
    // Handle form submission.
    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        let error = null;
        try {

            stripe.confirmPayment({
                elements,

                redirect: "if_required",
                payment_method_data: {
                    billing_details: {
                        name: document.getElementById("buyerFullName"),
                        email: document.getElementById("buyerEmail")
                    }
                },
            })
                .then(function (result) {
                    console.log(result);
                    error = result.error;
                    if (error) {
                        console.error(error.message);
                    }
                });
        } catch (error) {
            console.error(error);
        }
    });
}

function StartBankPayment() {
    SelectDirectPayment();
    ShowBankPayment(true);
}

function ShowBankPayment(show) {
    if (show) {
        document.getElementById("payment-form-card").style.display = "none";
        document.getElementById("payment-form-bank").style.display = "block";
    }
    else {
        document.getElementById("payment-form-card").style.display = "block";
        document.getElementById("payment-form-bank").style.display = "none";
    }
    ClearQrCodeDiv();
    ToggleSpinner(false);
}
function StartCardPayment() {
    SelectCardPayment(true);
    ShowBankPayment(false);
    SendXmlHttpRequest("../Payout/API/InitiateCardPayment.ws",
        {
            "tabId": TabID
        },
        (response) => {
            if (!response.OK) {
                TransactionFailed(null);
            }
        },
        (error) => {
            if (error.status === 408) {
                return;
            }
            alert(error);
            TransactionFailed(null);
        })
}

function SelectDirectPayment() {
    SelectCardPayment(false);
    ExpandOtherPaymentMethods(false);
}

function ExpandOtherPaymentMethods(expand) {
    if (expand) {
        document.getElementById("payment-other-methods").style.display = "none";
        document.getElementById("payment-card-tbl").style.display = "block";
    }
    else {
        document.getElementById("payment-other-methods").style.display = null;
        document.getElementById("payment-card-tbl").style.display = "none";
    }
}

function SelectCardPayment(selected) {
    if (selected) {
        document.getElementById("payment-notice-lbl").style.display = "none";
        document.getElementById("payment-bank-btn").style.display = "none";
        selectPaymentBtn("payment-card-btn");
        unSelectPaymentBtn("payment-direct-bank-btn");
    }
    else {
        document.getElementById("payment-notice-lbl").style.display = null;
        document.getElementById("payment-bank-btn").style.display = null;
        selectPaymentBtn("payment-direct-bank-btn");
        unSelectPaymentBtn("payment-card-btn");
    }
}

function selectPaymentBtn(elementId) {
    var cardBtn = document.getElementById(elementId);
    cardBtn.classList.add("payment-btn-selected");
}

function unSelectPaymentBtn(elementId) {
    var directBankBtn = document.getElementById(elementId);
    directBankBtn.classList.remove("payment-btn-selected");
}

function CollapseDetails() {
    document.getElementById("tr_header").style.display = "none";
    document.getElementById("tr_header_title").style.display = "none";
    document.getElementById("tr_fees").style.display = "none";
    document.getElementById("tr_space").style.display = "none";
    document.getElementById("tr_summary").addEventListener("click", ExpandDetails);
}

function ExpandDetails() {
    document.getElementById("tr_header").style.display = null;
    document.getElementById("tr_header_title").style.display = null;
    document.getElementById("tr_summary").style.display = null;
    document.getElementById("tr_fees").style.display = null;
    document.getElementById("tr_space").style.display = null;
    document.getElementById("tr_header").addEventListener("click", CollapseDetails);
    document.getElementById("tr_header_title").addEventListener("click", CollapseDetails);
}

