function StateChanged(Control) {
    if (window.confirm("Confirm you want to change the state of this legal identity to " + Control.value)) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function () {
            if (xhttp.readyState == 4) {
                if (xhttp.status == 200) {
                    NotifyAboutChange(Control);
                    Control.setAttribute("data-prev", Control.value);
                }
                else {
                    ShowError(xhttp);
                }

                delete xhttp;
            }
        };

        xhttp.open("POST", "/LegalIdentityStateChanged", true);
        xhttp.setRequestHeader("Content-Type", "application/json");
        xhttp.send(JSON.stringify({
            "id": Control.getAttribute("data-id"),
            "state": Control.value
        }));
    }
    else {
        Control.value = Control.getAttribute("data-prev");
    }
}

function NotifyAboutChange(Control) {
    try {
        var xhttpNotification = new XMLHttpRequest();
        xhttpNotification.onreadystatechange = function () {
            if (xhttp.readyState == 4) {
                if (xhttpNotification.status != 200) {
                    ShowError(xhttpNotification);
                }

                delete xhttpNotification;
            }
        };

        xhttpNotification.open("POST", "/VaulterApi/PaymentLink/Mail/NotifyIdentityStateChanged.ws", true);
        xhttpNotification.setRequestHeader("Content-Type", "application/json");
        xhttpNotification.setRequestHeader("Accept", "application/json");
        xhttpNotification.send(JSON.stringify({
            "id": Control.getAttribute("data-id"),
            "state": Control.value
        }));
    } catch (error) {
    }
}
