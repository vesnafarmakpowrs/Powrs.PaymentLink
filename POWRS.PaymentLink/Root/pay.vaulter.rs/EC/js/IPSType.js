
var Translations = {};
const isMobileDevice = window.navigator.userAgent.toLowerCase().includes("mobi");

document.addEventListener("DOMContentLoaded", () => {
    GenerateTranslations();
});

function GenerateTranslations() {
    var element = document.getElementById("SelectedAccountOk");
    if (element == null) {
        return;
    }

    Translations.SessionTokenExpiredMessage = document.getElementById("SessionTokenExpired").value;
}



function PaymentCompleted(Result) {
    location.reload();
}

function getbanksIE(){
  var url = 'IPSBank.md?TYPE=IE';
  openBankListURL(url);
}

function getbanksLE(){
  
 var url = 'IPSBank.md?TYPE=LE';
 openBankListURL(url);
}

function openBankListURL(url) {
    
	var ID = document.getElementById('ID').value;
	console.log(ID);
   
    url = url + "&ID=" + ID.trim();
    window.open(url, '_PARENT');
}



  function infoPopup() { 
            const overlay = document.getElementById('popupOverlay'); 
            overlay.classList.toggle('show'); 
        } 


