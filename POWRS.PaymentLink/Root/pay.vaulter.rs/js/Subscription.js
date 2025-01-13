function PopulateAuthorizationForm(Data) {
    if (Data == null) {
        console.log("api response is null");
        return;
    }

    if (Data.Message != "") {
        alert(apiResponse.Message);
    }
    const apiResponse = Data.Response;
    console.log(apiResponse);

    const form = document.getElementById('authorizationForm');

    form.action = apiResponse.ActionUrl;
    form.querySelector('input[name="PAGE"]').value = apiResponse.Page;
    form.querySelector('input[name="AMOUNT"]').value = apiResponse.Amount;
    form.querySelector('input[name="CURRENCY"]').value = apiResponse.Currency;
    form.querySelector('input[name="LANG"]').value = apiResponse.Lang;
    form.querySelector('input[name="SHOPID"]').value = apiResponse.Shopid;
    form.querySelector('input[name="ORDERID"]').value = apiResponse.Orderid;
    form.querySelector('input[name="URLDONE"]').value = apiResponse.Urldone;
    form.querySelector('input[name="URLBACK"]').value = apiResponse.Urlback;
    form.querySelector('input[name="URLMS"]').value = apiResponse.Urlms;
    form.querySelector('input[name="ACCOUNTINGMODE"]').value = apiResponse.Accountingmode;
    form.querySelector('input[name="AUTHORMODE"]').value = apiResponse.Authormode;
    form.querySelector('input[name="OPTIONS"]').value = apiResponse.Options;
    form.querySelector('input[name="EMAIL"]').value = apiResponse.Email;
    form.querySelector('input[name="TRECURR"]').value = apiResponse.Trecurr;
    form.querySelector('input[name="EXPONENT"]').value = apiResponse.Exponent;
    form.querySelector('input[name="MAC"]').value = apiResponse.Mac;

    // Submit the form
    form.submit();
}
function InitiateCardAuthorization() {
    HideSubmitPaymentDiv();
    ShowHideElement("payspot-submit", "none");
    ShowHideElement("tr_spinner", null);
    CollapseDetails();

    SendXmlHttpRequest("../Payout/API/InitiateCardAuthorization.ws",
        {
            "isFromMobile": isMobileDevice,
            "tabId": TabID,
            "timeZoneOffset": new Date().getTimezoneOffset()
        },
        (response) => {
            PopulateAuthorizationForm(response);
        },
        (error) => {
            if (error.status === 408) {
                return;
            }
            alert(error);
            TransactionFailed(null);
        })
}
function UpdateBuyerInformations(btn) {
    btn.disabled = true;
    const fullName = document.querySelector('input[name="fullName"]').value;
    const email = document.querySelector('input[name="email"]').value;
    const address = document.querySelector('input[name="address"]').value;
    const city = document.querySelector('input[name="city"]').value;
    const phoneNumber = document.querySelector('input[name="phoneNumber"]').value;

    SendXmlHttpRequest("../Payout/API/UpdateBuyerInformations.ws",
        {
            "fullName": fullName,
            "email": email,
            "address": address,
            "city": city,
            "phoneNumber": phoneNumber
        },
        (response) => {
            location.reload();
        },
        (error) => {
            parsedError = JSON.parse(error.response);
            if (parsedError.length > 0) {
                parsedError.forEach(fieldName => {
                    const input = document.querySelector(`input[name="${fieldName}"]`);
                    if (input) {
                        input.style.border = '1px solid red';
                    }
                });
            }
            btn.disabled = false;
        })
}
function InitiateCancellation() {
    ShowHideElement("tr_spinner", null);
    SendXmlHttpRequest("../Payout/API/InitiateCancellation.ws",
        {},
        (response) => {
            setTimeout(function () {
                location.reload();
            }, 1000);
        },
        (error) => {
            if (error.status === 408) {
                return;
            }
            alert("There is an error");
        })
}
function StateUpdated(data) {
    setTimeout(function () {
        GenerateLanguageDropdown();
        GenerateTranslations();
    }, 1000);
}
