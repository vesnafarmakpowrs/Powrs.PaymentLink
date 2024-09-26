function ChangeClientType(Control) {
	try {
		var orgName = Control.getAttribute("data-name");
		var orgId = Control.getAttribute("data-id");

		if (window.confirm("Confirm you want to change the clients '" + orgName + "' type to '" + Control.value + "'")) {
			var xhttp = new XMLHttpRequest();
			xhttp.onreadystatechange = function () {
				if (xhttp.readyState == 4) {
					if (xhttp.status == 200) {
						Control.setAttribute("data-prev", Control.value);
						window.alert("Client type successfully changed.");
					}
					else {
						Control.value = Control.getAttribute("data-prev");
						window.alert("Error: " + xhttp);
					}

					delete xhttp;
				}
			};

			xhttp.open("POST", "/VaulterApi/PaymentLink/Onboarding/ChangeOrganizationClientType.ws", true);
			xhttp.setRequestHeader("Content-Type", "application/json");
			xhttp.setRequestHeader("Accept", "application/json");
			xhttp.send(JSON.stringify({
				"objectId": orgId,
				"type": Control.value
			}));
		} else {
			Control.value = Control.getAttribute("data-prev");
		}
	}
	catch (error) {
		Control.value = Control.getAttribute("data-prev");
		window.alert("Error: ", error);
	}
}