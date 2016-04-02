module Views.Login (Model, init, Action, view, mountedRoute) where

import Random exposing (initialSeed, Seed)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, class, href)
import Http
import Json.Encode
import Task
import Routes
import Api.Mondo as Mondo
import Signal
import Erl
import Prelude exposing (..)
import Storage


-- Model


type alias Model =
  { randomStateSeed : Seed
  , baseUrl : Erl.Url
  , redirectUrl : Erl.Url
  }


init : Int -> Erl.Url -> Model
init seed baseUrl =
  { randomStateSeed = initialSeed seed
  , baseUrl = baseUrl
  , redirectUrl = Erl.new
  }


mountedRoute : Model -> ( Model, Effects Action )
mountedRoute model =
  let
    returnUrl =
      Erl.appendPathSegments [ "receive" ] model.baseUrl

    ( url, state, seed' ) =
      Mondo.loginUrl model.randomStateSeed returnUrl
  in
    ( { model | randomStateSeed = seed', redirectUrl = url }
    , setStateInStorage state
    )



-- Update


type Action
  = StoredState (Result String ())



-- View


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ "width" => "200px" ] ]
    [ a [ href (Erl.toString model.redirectUrl) ] [ text "Login" ]
    ]



-- Effects


setStateInStorage : String -> Effects Action
setStateInStorage state =
  Storage.setItem Mondo.mondoOAuthStateKey (Json.Encode.string state)
    |> Task.toResult
    |> Task.map StoredState
    |> Effects.task
