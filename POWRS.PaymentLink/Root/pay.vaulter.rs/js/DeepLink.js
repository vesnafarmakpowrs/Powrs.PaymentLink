window.onload = function () {
    let urlInput = document.getElementById("deepLink");
    if (urlInput != undefined && urlInput != null && urlInput.value != '') {
        window.open(urlInput.value, "_self");
    }
};