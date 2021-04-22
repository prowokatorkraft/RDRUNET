const AuthorSelect = document.getElementById("AuthorIDs");
const AddModalBtn = document.getElementById("add-modal-author-btn");
const FirstNameModalText = document.getElementById("FirstName");
const LastNameModalText = document.getElementById("LastName");
const ModelModalValidation = document.getElementById("model-validation-field");
const FirstNameModalValidation = document.getElementById("firstName-validation-field");
const LastNameModalValidation = document.getElementById("lastName-validation-field");
const AuthorIDsSelectedList = AuthorIDs;
let AuthorList;
const xhr = new XMLHttpRequest();

function addChildAuthorSelect(key, value, isSelected, isDeleted) {
    let option = document.createElement("option");
    option.innerText = key;
    option.value = value;
    if (isSelected == true) {
        option.setAttribute("selected", "selected");
    }
    if (isDeleted == true) {
        option.setAttribute("style", "color:lightgray");
    }

    AuthorSelect.appendChild(option);
}
function deleteAllChildrenAuthorSelect() {
    for (let item of AuthorSelect.childNodes) {
        AuthorSelect.removeChild(item);
    }
}

function configureXhr() {
    const AuthorsPattern = new RegExp("\/Author\/GetList$");
    const AuthorErrorsPattern = new RegExp("\/Author\/Create$");

    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                if (AuthorsPattern.test(xhr.responseURL)) {
                    if (xhr.responseText != "") {
                        AuthorList = JSON.parse(xhr.responseText);
                        updateAuthorSelect();
                    }
                }
                else if (AuthorErrorsPattern.test(xhr.responseURL)) {
                    if (xhr.responseText == "\"\"") {
                        clearModal();
                        requestAuthorListAjax();
                    }
                    else {
                        let errors = JSON.parse(xhr.responseText);
                        for (var item of errors) {
                            switch (item.Field) {
                                case "Model":
                                    ModelModalValidation.innerText = item.Description;
                                    break;
                                case "FirstName":
                                    FirstNameModalValidation.innerText = item.Description;
                                    break;
                                case "LastName":
                                    LastNameModalValidation.innerText = item.Description;
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
    FirstNameModalText.value = "";
    LastNameModalText.value = "";
    ModelModalValidation.innerText = "";
    FirstNameModalValidation.innerText = "";
    LastNameModalValidation.innerText = "";
}
function requestAuthorListAjax() {
    xhr.open("GET", '/Author/GetList');
    xhr.send(null);
}
function requestCreateAuthorAjax(author) {
    xhr.open("POST", '/Author/Create');
    xhr.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
    xhr.send(JSON.stringify({ author: author }));
}
function updateAuthorSelect() {
    deleteAllChildrenAuthorSelect();

    let isSelected = false;
    for (var item1 of AuthorList) {
        for (var item2 of AuthorIDsSelectedList) {
            if (item1.Id == item2) {
                isSelected = true;
            }
        }

        addChildAuthorSelect(item1.FirstName + " " + item1.LastName, item1.Id, isSelected, item1.IsDeleted);
        isSelected = false;
    }
}

configureXhr();
requestAuthorListAjax();
AddModalBtn.onclick = () => {
    let author = { FirstName: FirstNameModalText.value, LastName: LastNameModalText.value };
    requestCreateAuthorAjax(author);
};
