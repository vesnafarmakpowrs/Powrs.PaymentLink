
function ShowHideElement(id, display) {
    if (document.getElementById(id) != null)
        document.getElementById(id).style.display = display;
}

function AddEventListener(elementId, eventName, Event) {
    if (document.getElementById(elementId) != null)
        document.getElementById(elementId).addEventListener(eventName, Event);
}

function CollapseDetails() {
    ShowHideElement("tr_header", "none");
    ShowHideElement("tr_header_title", "none");
    ShowHideElement("tr_summary", "click", ExpandDetails);
}

function ExpandDetails() {
    ShowHideElement("tr_header", null);
    ShowHideElement("tr_header_title", null);
    ShowHideElement("tr_summary", null);
    AddEventListener("tr_header", "click", CollapseDetails);
    AddEventListener("tr_header_title", "click", CollapseDetails);
}

function ExpandSellerDetails() {
    ShowHideElement("tr_seller_dtl", null);
    expand_img = document.getElementById("expand_img");
    expand_img.src = "../resources/expand-up.svg";
    expand_img.removeEventListener('click', ExpandSellerDetails);
    expand_img.addEventListener("click", CollapseSellerDetails);
}

function CollapseSellerDetails() {
    ShowHideElement("tr_seller_dtl", "none");
    expand_img = document.getElementById("expand_img");
    expand_img.src = "../resources/expand-down.svg";
    expand_img.removeEventListener('click', CollapseSellerDetails);
    expand_img.addEventListener("click", ExpandSellerDetails);
}

function OpenTermsAndConditions(event, element) {
    event.preventDefault();

    var href = element.getAttribute('urlhref');
    if (href == null) {
        return;
    }
    if (href.startsWith('http://') || href.startsWith('https://')) {
        openWebURL(href);
    }
    else {
        openBase64String(href);
    }
}

function openWebURL(url) {
    window.open(url, '_blank');
}

function openBase64String(base64String) {
    var binaryString = window.atob(base64String);
    var bytes = new Uint8Array(binaryString.length);
    for (var i = 0; i < binaryString.length; i++) {
        bytes[i] = binaryString.charCodeAt(i);
    }

    // Create a Blob from the Uint8Array
    var blob = new Blob([bytes], { type: 'application/pdf' });

    // Create a temporary URL for the Blob
    var blobURL = URL.createObjectURL(blob);

    // Open a new window with the Blob URL
    var newWindow = window.open(blobURL);
}

