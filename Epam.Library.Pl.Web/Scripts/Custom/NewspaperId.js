const NewspaperSelect = document.getElementById("NewspaperId");
const NewspaperIdSelected = newspaperIdSelected;
const AddModalBtn = document.getElementById("add-modal-newspaper-btn");
const NameModalText = document.getElementById("NameModal");
const IssnModalText = document.getElementById("ISSN");
const ModelModalValidation = document.getElementById("model-validation-field");
const NameModalValidation = document.getElementById("name-validation-field");
const IssnModalValidation = document.getElementById("issn-validation-field");
let NewspaperList;
const xhr = new XMLHttpRequest();

function addChildNewspaperSelect(key, value, isSelected, isDeleted) {
    let option = document.createElement("option");
    option.innerText = key;
    option.value = value;
    if (isSelected == true) {
        option.setAttribute("selected", "selected");
    }
    if (isDeleted == true) {
        option.setAttribute("style", "color:lightgray");
    }

    NewspaperSelect.appendChild(option);
}
function deleteAllChildrenNewspaperSelect() {
    for (let item of NewspaperSelect.childNodes) {
        NewspaperSelect.removeChild(item);
    }
}

function configureXhr() {
    const NewspapersPattern = new RegExp("\/Newspaper\/GetList$");
    const NewspaperErrorsPattern = new RegExp("\/Newspaper\/Create$");

    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                if (NewspapersPattern.test(xhr.responseURL)) {
                    if (xhr.responseText != "") {
                        NewspaperList = JSON.parse(xhr.responseText);
                        updateNewspaperSelect();
                    }
                }
                else if (NewspaperErrorsPattern.test(xhr.responseURL)) {
                    if (xhr.responseText == "\"\"") {
                        clearModal();
                        requestNewspaperListAjax();
                    }
                    else {
                        let errors = JSON.parse(xhr.responseText);
                        for (var item of errors) {
                            switch (item.Field) {
                                case "Model":
                                    ModelModalValidation.innerText = item.Description;
                                    break;
                                case "Name":
                                    NameModalValidation.innerText = item.Description;
                                    break;
                                case "ISSN":
                                    IssnNameModalValidation.innerText = item.Description;
                                    break;
                            }
                        }
                    }
                }
            }
        }
    }
}
function clearModal() {
    NameModalText.value = "";
    IssnModalText.value = "";
    ModelModalValidation.innerText = "";
    NameModalValidation.innerText = "";
    IssnModalValidation.innerText = "";
}
function requestNewspaperListAjax() {
    xhr.open("GET", '/Newspaper/GetList');
    xhr.send(null);
}
function requestCreateNewspaperAjax(newspaper) {
    xhr.open("POST", '/Newspaper/Create');
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({ newspaper: newspaper }));
}
function updateNewspaperSelect() {
    deleteAllChildrenNewspaperSelect();

    let isSelected = false;
    for (var item of NewspaperList) {
        if (item.Id == NewspaperIdSelected) {
            isSelected = true;
        }

        addChildNewspaperSelect(item.Name, item.Id, isSelected, item.IsDeleted);
        isSelected = false;
    }
}

configureXhr();
requestNewspaperListAjax();
AddModalBtn.onclick = () => {
    let newspaper = { Name: NameModalText.value, ISSN: IssnModalText.value };
    requestCreateNewspaperAjax(newspaper);
};