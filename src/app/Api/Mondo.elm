module Api.Mondo exposing (..)

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
                    [ "client_id" => Settings.mondoClientID
                    , "redirect_uri" => Erl.toString redirectUrl
                    , "response_type" => "code"
                    , "state" => state
                    ]
        }



-- Access Token


type alias AuthDetails =
    { accessToken : String
    , expiresIn : Int
    , userID : String
    }


exchangeAuthCode : String -> Erl.Url -> Task (Error String) AuthDetails
exchangeAuthCode code redirectUrl =
    let
        data =
            [ "grant_type" => "authorization_code"
            , "client_id" => Settings.mondoClientID
            , "client_secret" => Settings.mondoClientSecret
            , "redirect_uri" => Erl.toString redirectUrl
            , "code" => code
            ]
    in
        post "https://api.getmondo.co.uk/oauth2/token"
            |> withUrlEncodedBody data
            |> withHeader "Content-type" "application/x-www-form-urlencoded"
            |> send (jsonReader decodeAuthDetails) stringReader
            |> Task.map (\response -> response.data)


decodeAuthDetails : JD.Decoder AuthDetails
decodeAuthDetails =
    JD.object3
        AuthDetails
        ("access_token" := JD.string)
        ("expires_in" := JD.int)
        ("user_id" := JD.string)
