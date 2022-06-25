function reloadTodos(trackingId, delay) {
  setTimeout(reloadTodos, delay, trackingId);
}

function onDocumentLoad() {
  alert("doc load");
}

window.onload = onDocumentLoad;
