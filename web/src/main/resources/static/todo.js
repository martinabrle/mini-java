function reloadTodos(trackingId, delay) {
  setTimeout(reloadTodos, delay, trackingId);
}

function checkTodoSaved(id, repeats) {
  fetch(`/todos/${id}`)
    .then((response) => {
      if (response.ok) {
        response.text().then((text) => {
            console.log("response ok and response body received:\n" + text);
            return;
          }).catch((reason) => {
            console.log(
              "response ok but exception when fetching body:\n" + reason
            );
          });
      } else {
        console.log("response NOT ok :\n" + response.status);
      }
    }).catch((reason) => {
      console.log("Fetch returned an error :\n" + reason);
    });
  repeats--;
  if (repeats > 0) {
    setTimeout(checkTodoSaved, 200, id, repeats);
  }
}
//     response.json().then((json) => {
//       alert("got json: " + json);
//     }).catch((reason) => {
//       alert("something went wrong: " + reason);
//     });
//     alert("Something went wrong!");
//   }
// }).catch((reason) => {
//   console.log("error while fetching URL:" + reason);
// });

// if (!response.ok) {
//   throw new Error("Something went wrong!");
// }

// const data = await response.json();

// const loadedMovies = [];

// for (const key in data) {
//   loadedMovies.push({
//     id: key,
//     title: data[key].title,
//     openingText: data[key].openingText,
//     releaseDate: data[key].releaseDate,
//   });
// }

// setMovies(loadedMovies);

//setTimeout(checkTodoSaved, 10000);

function onDocumentLoad() {
  //let messageBox = document.getElementById("message-box");
  //alert(checkStatusAsync);
  //alert(trackingId);
  if (
    typeof checkStatusAsync !== "undefined" &&
    typeof trackingId !== "undefined" &&
    checkStatusAsync === true
  ) {
    checkTodoSaved(trackingId, 20);
    //todo - use thius setTimeout(checkTodoSaved, 200, trackingId, 50);
  }
}

window.onload = onDocumentLoad;
