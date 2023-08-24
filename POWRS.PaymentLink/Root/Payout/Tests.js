var updateTimer = null;

function OpenBankIDApp(AppUrl, SessionId, RequestFromMobilePhone, QrCodeUsed)
{
	RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed);

var Div = document.getElementById("TestStatus");

	Div.innerHTML = "in showQRCode" + encodeURIComponent(AppUrl) ;


	window.open(AppUrl,"_self");
}

function StartQrCodeAnimation(SessionId, RequestFromMobilePhone, QrCodeUsed)
{
	RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed);
	updateTimer = window.setInterval(UpdateQrCode, 1000);
}


function GetAccountInfo(RequestFromMobilePhone)
{
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
                        "bicFi":selectedServiceProvider.C2,
                        "bankName": selectedServiceProvider.C1,
			"contractId": document.getElementById("contractId").value
		}));

}

function StartPayment(RequestFromMobilePhone)
{
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");
console.log(TabID + "ismobiledevice:" + isMobileDevice );
console.log(window.navigator.userAgent.toLowerCase());
var xhttp = new XMLHttpRequest();
	xhttp.open("POST", "InitiatePayment.ws", true);
	xhttp.setRequestHeader("Content-Type", "application/json");
	xhttp.setRequestHeader("Accept", "application/json");
	xhttp.send(JSON.stringify(
		{
			"tabId": TabID,
			"sessionId": "",
			"requestFromMobilePhone": Boolean(isMobileDevice)
		}));

}


function RegisterUpdateNotifications(SessionId, RequestFromMobilePhone, QrCodeUsed)
{
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


function UpdateQrCode()
{
	var Img = document.getElementById("AnimatedQrCode");
	if (!Img)
		return;

	var SessionId = Img.getAttribute("data-sessionId");

	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function ()
	{
		if (xhttp.readyState === 4)
		{
			if (xhttp.status === 200)
			{
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

function StopAnimation()
{
	if (updateTimer)
	{
		window.clearInterval(updateTimer);
		updateTimer = null;

		var Img = document.getElementById("AnimatedQrCode");
		if (Img)
			Img.setAttribute("style", "display:none");
	}
}

function SessionUpdated(Data)
{
	var SessionStatus = document.getElementById("SessionStatus");
        console.log(SessionStatus);
        console.log(Data);
        console.log(JSON.stringify(Data, null, 2));

        console.log(SessionStatus.innerText);
	SessionStatus.innerText = JSON.stringify(Data, null, 2);

	var Message = document.getElementById("Message");
	Message.innerText = Data.messageEnglish;

	switch (Data.status)
	{
		case "complete":
		case "failed":
			StopAnimation();
			break;
	}
}
