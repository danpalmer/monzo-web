module Settings exposing (..)

import Erl


-- Monzo API Details
-- (Not secret these are safe to publish)


monzoAuthBase =
    Erl.parse "https://auth.getmondo.co.uk/"


monzoApiBase =
    Erl.parse "https://api.getmondo.co.uk/"


monzoClientID =
    "oauthclient_0000968G0rIJ6Uc40n0iHZ"


monzoOwnerID =
    "user_0000926xerDCYFv7qBtaNd"


monzoClientSecret =
    "Y/qw1c4pA8+3rHDch58n6Aw7CNj0W1oWS/n2Rkv+CLkCaRjBkeTia7yQ7JrNMeA2wQPcoJ8Y+lDpd5P5RXo6"


monzoOAuthStateKey =
    "monzoOAuthState"


authDetailsKey =
    "authDetails"
