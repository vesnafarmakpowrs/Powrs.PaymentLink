var Translations = {};
document.addEventListener("DOMContentLoaded", () => {
   GenerateTranslations();
});

function GenerateTranslations() {
    Translations.SessionTokenExpiredMessage = document.getElementById("SessionTokenExpired").value;
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
