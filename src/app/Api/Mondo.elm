module Api.Mondo (..) where

import Erl
import Dict
import Random exposing (generate, Seed)
import Random.Char exposing (english)
import Random.String exposing (string)
import Settings
import Prelude exposing (..)


stateGenerator : Random.Generator String
stateGenerator =
  string 20 english


randomState : Seed -> ( String, Seed )
randomState seed =
  generate stateGenerator seed


loginUrl : Seed -> Erl.Url -> ( Erl.Url, Seed )
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
    , seed'
    )
