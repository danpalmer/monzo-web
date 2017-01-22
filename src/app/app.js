require("../styles/app.scss");

var Elm = require('./Main');

var baseUrl = (
    window.location.protocol + '//' +
    window.location.hostname +
    (window.location.port ? ':' + window.location.port : '')
);

var currentMilliseconds = (new Date()).getTime();

Elm.Main.fullscreen({
    initialSeed: currentMilliseconds,
    startTime: currentMilliseconds,
    baseUrl: baseUrl,
    query: window.location.search
});
