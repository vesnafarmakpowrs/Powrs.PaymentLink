function CollapseDetails() {
    document.getElementById("tr_header").style.display = "none";
    document.getElementById("tr_header_title").style.display = "none";
    document.getElementById("tr_summary").addEventListener("click", ExpandDetails);
}

function ExpandDetails() {
    document.getElementById("tr_header").style.display = null;
    document.getElementById("tr_header_title").style.display = null;
    document.getElementById("tr_summary").style.display = null;
    document.getElementById("tr_header").addEventListener("click", CollapseDetails);
    document.getElementById("tr_header_title").addEventListener("click", CollapseDetails);
}

function ExpandSellerDetails() {
    document.getElementById("tr_seller_dtl").style.display = null;
    expand_img = document.getElementById("expand_img");
    expand_img.src = "../resources/expand-up.svg";
    expand_img.removeEventListener('click', ExpandSellerDetails);
    expand_img.addEventListener("click", CollapseSellerDetails);
}

function CollapseSellerDetails() {
    document.getElementById("tr_seller_dtl").style.display = "none";
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

