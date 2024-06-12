function AllowEditOnboarding(id, userName) {

    try {
        if (window.confirm("Confirm you want to allow user : '" + userName + "' to modify onboarding data?")) {
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function () {
                if (xhttp.readyState == 4) {
                    if (xhttp.status == 200) {
                        document.getElementById("btnAllowEdit_" + id).style.display = 'none';
                        document.getElementById("lblCanEdit_" + id).innerHTML = "Yes";
                        window.alert("User is allowed to edit onboarding data.");
                    }
                    else
                        window.alert("xhttp.status != 200", xhttp);

                    delete xhttp;
                }
            };

            xhttp.open("POST", "/VaulterApi/PaymentLink/Onboarding/AllowEdit.ws", true);
            xhttp.setRequestHeader("Content-Type", "application/json");
            xhttp.setRequestHeader("Accept", "application/json");
            xhttp.send(JSON.stringify({
                "ObjectId": id
            }));
        }
    }
    catch (error) {
        window.alert("Error: ", error);
    }
}

function ViewOnboarding(id, userName) {

    try {
        url = "/Payout/ViewOnboarding.md?ObjectId=" + id;
        window.open(url, '_blank');
    }
    catch (error) {
        window.alert("Error: ", error);
    }
}