require("../styles/app.scss");

var Elm = require('./Main');

Elm.embed(
  Elm.Main,
  document.getElementById('main'),
  {
    initialPath: window.location.pathname
  }
);
