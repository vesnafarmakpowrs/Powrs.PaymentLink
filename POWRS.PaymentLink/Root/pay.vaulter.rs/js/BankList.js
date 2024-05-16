document.addEventListener('DOMContentLoaded', function () {
    let dropdown = document.querySelector(".dropdown");
    let selectCountry = dropdown.querySelector(".select-bank");
    let options = dropdown.querySelector(".options");
    let optionItems = options.querySelectorAll("div");
    // Other code...
 
    
    const toggleDropdown = () => {
        if (window.getComputedStyle(options).display == "none") {
            options.style.display = "block";
        }
        else {
            options.style.display = "none";
        }           
    }   
    selectCountry.addEventListener("click", toggleDropdown);
    
    
    const chooseOption = (option) => {
        console.log(option.getAttribute("data-value")); 
        toggleDropdown();
    }
    optionItems.forEach(function(option, i) {
        option.addEventListener("click", function(){chooseOption(option)});
    });
    
    const closeDropdown = (e) => {
        if (e.target.parentNode.className !== "dropdown") {
            options.style.display = "none";
        }
    }
    document.addEventListener("click", closeDropdown);
});