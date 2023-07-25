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
			if(selectedServiceProvider == null){
				return;
			}
			console.log(selectedServiceProvider);
			StartPayment(selectedServiceProvider.C1, selectedServiceProvider.C2,account.Iban);
		}
		container.appendChild(bankElement);
	});
}


function StartPayment(bankName, bicFi, iban) {
	let contractId = document.getElementById('contractId').value;
	const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");
	var xhttp = new XMLHttpRequest();
	xhttp.open("POST", "BuyEdaler.ws", true);
	xhttp.setRequestHeader("Content-Type", "application/json");
	xhttp.setRequestHeader("Accept", "application/json");
	xhttp.send(JSON.stringify(
		{
			"tabId": TabID,
			"sessionId": "",
			"requestFromMobilePhone": Boolean(isMobileDevice),
			"bicFi": bicFi,
			"bankName": bankName,
			"countryCode": "SE",
			"contractId": contractId,
			"bankAccount": iban
		}));

}

function DisplayTransactionResult(result)
{
   console.log(result);
   var Div = document.getElementById("QrCode");
   Div.innerHTML = result.message;

//let contractId = document.getElementById('contractId').value;
//	var xhttp = new XMLHttpRequest();
//	xhttp.open("POST", "VaulterState.ws", true);
//	xhttp.setRequestHeader("Content-Type", "application/json");
//	xhttp.setRequestHeader("Accept", "application/json");
//	xhttp.send(JSON.stringify(
//		{
//			"contractId": contractId
//		}));


}


function OpenUrl(Url) {
	var Window = window.open(Url, "_blank");
	Window.focus();
}

function ShowQRCode(Data) {
	console.log(Data);
	var Div = document.getElementById("QrCode");
	Div.innerHTML = "in URL: " + encodeURIComponent(Data.url) + "Data.fromMobileDevice: " + Data.fromMobileDevice;

       if (Data.ImageUrl != null)
	{
		Div.innerHTML = "<fieldset><legend>" + Data.title + "</legend><p>" + Data.message +
			"</p><p><img alt='Bank ID QR Code' src='" + Data.ImageUrl + "'/></p></fieldset>";
	}
       else if (!Data.fromMobileDevice)
       {
	  Div.innerHTML = "<fieldset><legend>" + Data.title + "</legend><p>" + Data.message +
		"</p><p>" + "<a href='" + Data.AutoStartToken + "'><img alt='Bank ID QR Code' src='/QR/" +
		encodeURIComponent(Data.AutoStartToken) + "'/></a></p></fieldset>";
	}
	else 
       {
		Div.innerHTML = "Opening authorization link." + Data.BankIdUrl;
		window.open(Data.BankIdUrl, "_self")
	}
}

function PaymentError(Data) {
	var Div = document.getElementById("QrCode");
	Div.innerHTML = "<fieldset><legend>Error</legend><p>" + Data + "</p></fieldset>";
}