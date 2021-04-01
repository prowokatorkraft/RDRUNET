const AuthorSelect = document.getElementById("AuthorIDs");
let AuthorIDsSelectedList = AuthorIDs;
let AuthorList;
let xhr = new XMLHttpRequest();

function addChildAuthorSelect(key, value, isSelected) {
    let option = document.createElement("option");
    option.innerText = key;
    option.value = value;
    if (isSelected == true) {
        option.setAttribute("selected", "selected");
    }

    AuthorSelect.appendChild(option);
}
function deleteAllChildrenAuthorSelect() {
    for (let item of AuthorSelect.childNodes) {
        AuthorSelect.removeChild(item);
    }
}

function configureXhr() {
    xhr.onreadystatechange = function () {
        if (xhr.readyState == 4) {
            if (xhr.status == 200) {
                if (xhr.responseText != "") {
                    AuthorList = JSON.parse(xhr.responseText);

                    updateAuthorSelect();
                }
            }
        }
    }
}
function requestAuthorListAjax() {
    xhr.open("Post", '/Author/GetList');
    xhr.send(null);
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

        addChildAuthorSelect(item1.FirstName + " " + item1.LastName, item1.Id, isSelected);
        isSelected = false;
    }
}

configureXhr();
requestAuthorListAjax();
