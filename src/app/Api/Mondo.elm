module Api.Mondo (..) where

import Erl
import Dict
import Http
import Http.Extra exposing (..)
import String exposing (..)
import Task exposing (..)
import Effects exposing (Effects)
import Random exposing (generate, Seed)
import Random.Char exposing (english)
import Random.String exposing (string)
import Settings
import Prelude exposing (..)
import Storage
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))


-- Login


stateGenerator : Random.Generator String
stateGenerator =
  string 20 english


randomState : Seed -> ( String, Seed )
randomState seed =
  generate stateGenerator seed


loginUrl : Seed -> Erl.Url -> ( Erl.Url, String, Seed )
loginUrl seed redirectUrl =
  let
    url =
      Erl.parse "https://auth.getmondo.co.uk/"

    ( state, seed' ) =
      (randomState seed)
  in
    ( { url
        | query =
            Dict.fromList
              [ "client_id" => mondoClientID
              , "redirect_uri" => Erl.toString redirectUrl
              , "response_type" => "code"
              , "state" => state
              ]
      }
    , state
    , seed'
    )



-- Access Token


type alias AuthDetails =
  { accessToken : String
  , expiredIn : Int
  , refreshToken : String
  , userID : String
  }


exchangeAuthCode : String -> Erl.Url -> Task never (Maybe AuthDetails)
exchangeAuthCode code redirectUrl =
  let
    data =
      [ "grant_type" => "authorization_code"
      , "client_id" => mondoClientID
      , "client_secret" => mondoClientSecret
      , "redirect_uri" => Erl.toString redirectUrl
      , "code" => code
      ]
  in
    post "https://api.getmondo.co.uk/oauth2/token"
      |> withUrlEncodedBody data
      |> withHeader "Content-type" "application/x-www-form-urlencoded"
      |> send (jsonReader decodeAuthDetails) stringReader
      |> Task.map (\response -> response.data)
      |> Task.toMaybe


decodeAuthDetails : JD.Decoder AuthDetails
decodeAuthDetails =
  JD.object4
    AuthDetails
    ("access_token" := JD.string)
    ("expires_in" := JD.int)
    ("refresh_token" := JD.string)
    ("user_id" := JD.string)



-- Constants


mondoClientID =
  "oauthclient_0000968G0rIJ6Uc40n0iHZ"


mondoClientSecret =
  "Y/qw1c4pA8+3rHDch58n6Aw7CNj0W1oWS/n2Rkv+CLkCaRjBkeTia7yQ7JrNMeA2wQPcoJ8Y+lDpd5P5RXo6"


mondoOAuthStateKey =
  "mondoOAuthState"



--exchangeAuthCode : String -> Effects Action
--exchangeAuthCode topic =
--  Http.get decodeImageUrl (randomUrl topic)
--    |> Task.toMaybe
--    |> Task.map NewGif
--    |> Effects.task
--randomUrl : String -> String
--randomUrl topic =
--  Http.url
--    "http://api.giphy.com/v1/gifs/random"
--    [ "api_key" => "dc6zaTOxFJmzC"
--    , "tag" => topic
--    ]
--decodeImageUrl : Json.Decoder String
--decodeImageUrl =
--  Json.at [ "data", "image_url" ] Json.string
