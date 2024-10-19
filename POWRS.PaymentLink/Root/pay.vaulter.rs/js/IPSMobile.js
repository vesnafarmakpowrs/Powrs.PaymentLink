function getbanksIE()
{
    var url = 'IPSBank.md';
    openBankListURL(url, "&TYPE=IE");
}

function getbanksLE()
{

    var url = 'IPSBank.md';
    openBankListURL(url, "&TYPE=LE");
}

function openBankListURL(url, parameter)
{
    var jwt = parent.document.getElementById('jwt').value;

    console.log(jwt);
    if (jwt == "")
    {
        alert("Session token not found, refresh the page and try again");
    }

    url = url + "&JWT=" + jwt.trim();
    window.parent.location.href = window.parent.location.href + parameter;
    console.log(window.parent.location.href);
    // window.open(url, '_PARENT');
}

function infoPopup()
{
    const overlay = document.getElementById('popupOverlay');
    overlay.classList.toggle('show');
}


