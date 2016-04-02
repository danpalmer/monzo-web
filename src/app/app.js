require("../styles/app.scss");

var Elm = require('./Main');

var baseUrl = (
  window.location.protocol + '//' +
  window.location.hostname +
  (window.location.port ? ':' + window.location.port : '')
);

Elm.embed(
  Elm.Main,
  document.getElementById('main'),
  {
    initialPath: window.location.pathname,
    initialSeed: (new Date()).getTime(),
    baseUrl: baseUrl,
    query: window.location.search
  }
);
