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


loginUrl : Seed -> ( String, Seed )
loginUrl seed =
  let
    url =
      Erl.parse "https://auth.getmondo.co.uk/"

    ( state, seed' ) =
      (randomState seed)
  in
    ( Erl.toString
        { url
          | query =
              Dict.fromList
                [ "client_id" => "red"
                , "redirect_uri" => "10"
                , "response_type" => "code"
                , "state" => state
                ]
        }
    , seed'
    )
