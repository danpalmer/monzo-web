module Api.Monzo exposing (..)

import Erl
import Dict
import Http
import HttpBuilder exposing (..)
import String exposing (..)
import Task exposing (..)
import Platform.Cmd exposing (Cmd)
import Settings
import Prelude exposing (..)
import LocalStorage
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))


-- Login


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



-- Access Token


type alias ApiAuthDetails =
    { accessToken : String
    , expiresIn : Int
    , userID : String
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


decodeApiAuthDetails : JD.Decoder ApiAuthDetails
decodeApiAuthDetails =
    JD.object3
        ApiAuthDetails
        ("access_token" := JD.string)
        ("expires_in" := JD.int)
        ("user_id" := JD.string)
