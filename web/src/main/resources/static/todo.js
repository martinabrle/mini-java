function reloadTodos(trackingId, delay) {
  setTimeout(reloadTodos, delay, trackingId);
}

function checkTodoSaved(id) {
  alert("check");
  fetch("/processingStatus?trackingId=${id}").then((response) => {
    alert("ok");
    alert(response);
  }).catch((reason) => {
    alert("error");
    alert(reason);
  });
  //setTimeout(checkTodoSaved, 10000);
}

function onDocumentLoad() {
  alert("doc load");
  let messageBox = document.getElementById("message-box");
  if (typeof checkStatusAsync !== 'undefined' && typeof trackingId !== 'undefined' && checkStatusAsync === true) {
    setTimeout(checkTodoSaved, 10000, trackingId);
  }
}

window.onload = onDocumentLoad;
