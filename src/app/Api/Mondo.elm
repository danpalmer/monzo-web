module Api.Mondo (..) where

import Erl
import Dict
import Http
import Task exposing (..)
import Effects exposing (Effects)
import Random exposing (generate, Seed)
import Random.Char exposing (english)
import Random.String exposing (string)
import Settings
import Prelude exposing (..)
import Storage
import Json.Encode as JE
import Json.Decode as JD


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
              [ "client_id" => "oauthclient_0000968G0rIJ6Uc40n0iHZ"
              , "redirect_uri" => Erl.toString redirectUrl
              , "response_type" => "code"
              , "state" => state
              ]
      }
    , state
    , seed'
    )



-- Constants


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
