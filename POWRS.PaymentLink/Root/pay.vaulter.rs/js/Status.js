document.addEventListener("DOMContentLoaded", function () {
    window.onload = function () {
        var successUrlElement = document.getElementById('RedirectUrl');
        if (successUrlElement) {
            var url = successUrlElement.value;
            setTimeout(function () {
                window.open(url, "_self");
            }, 3000);
        }
    };
});