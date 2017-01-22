module Settings exposing (..)

import Erl


-- Monzo API Details
-- (Not secret these are safe to publish)


monzoAuthBase : Erl.Url
monzoAuthBase =
    Erl.parse "https://auth.getmondo.co.uk/"


monzoApiBase : Erl.Url
monzoApiBase =
    Erl.parse "https://api.monzo.com/"


monzoClientID : String
monzoClientID =
    "oauthclient_00009GeYmZ5UZrrT6ERwKv"


monzoOwnerID : String
monzoOwnerID =
    "user_0000926xerDCYFv7qBtaNd"


monzoClientSecret : String
monzoClientSecret =
    "xsm7i0fQ/cLMq1wIhwo9iE34m6USqFUuiI6g6qbVjo1ELdqgb1h/tEtHPoG1vvryv7XdjWaraIa3ju0lCSZB"


monzoOAuthStateKey : String
monzoOAuthStateKey =
    "monzoOAuthState"


authDetailsKey : String
authDetailsKey =
    "authDetails"
