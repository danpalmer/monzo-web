module Api.Monzo exposing (..)

import Http
import Dict
import Task exposing (..)
import Erl
import HttpBuilder exposing (..)
import Settings
import Prelude exposing (..)
import Api.Monzo.Models exposing (ApiAuthDetails)
import Api.Monzo.Decoder exposing (decodeApiAuthDetails)


loginUrl : String -> Erl.Url -> Erl.Url
loginUrl state redirectUrl =
    let
        url =
            Erl.parse "https://auth.getmondo.co.uk/"
    in
        { url
            | query =
                Dict.fromList
                    [ "client_id" => Settings.monzoClientID
                    , "redirect_uri" => Erl.toString redirectUrl
                    , "response_type" => "code"
                    , "state" => state
                    ]
        }


exchangeAuthCode : String -> Erl.Url -> Task (Error String) ApiAuthDetails
exchangeAuthCode code redirectUrl =
    let
        data =
            [ "grant_type" => "authorization_code"
            , "client_id" => Settings.monzoClientID
            , "client_secret" => Settings.monzoClientSecret
            , "redirect_uri" => Erl.toString redirectUrl
            , "code" => code
            ]
    in
        post "https://api.getmondo.co.uk/oauth2/token"
            |> withUrlEncodedBody data
            |> withHeader "Content-type" "application/x-www-form-urlencoded"
            |> send (jsonReader decodeApiAuthDetails) stringReader
            |> Task.map (\response -> response.data)
