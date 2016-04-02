module Views.ReceiveAuth (Model, init, Action, update, view, mountedRoute) where

import Random exposing (initialSeed, Seed)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, class, href)
import Http
import Json.Decode
import Task
import Routes
import Api.Mondo as Mondo
import Signal
import Erl
import Prelude exposing (..)
import Dict exposing (Dict)
import String
import Storage
import Debug


-- Model


type AuthState
  = AuthLoading
  | AuthErrored
  | AuthDone


type alias Model =
  { receivedDetails : Dict String String
  , authState : AuthState
  , baseUrl : Erl.Url
  }


init : Dict String String -> Erl.Url -> Model
init receivedDetails baseUrl =
  { receivedDetails = receivedDetails
  , authState = AuthLoading
  , baseUrl = baseUrl
  }


mountedRoute : Model -> ( Model, Effects Action )
mountedRoute model =
  ( model, getStateFromStorage )



-- Update


type Action
  = LoadedState (Maybe String)
  | ReceiveAuthDetails (Maybe Mondo.AuthDetails)
  | Done


update : Action -> Model -> ( Model, Effects Action )
update msg model =
  case msg of
    LoadedState (Just state) ->
      if (isValidState model state) then
        ( { model | authState = AuthDone }
        , getAuthToken model
        )
      else
        ( { model | authState = AuthErrored }
        , Effects.none
        )

    LoadedState Nothing ->
      ( { model | authState = AuthErrored }
      , Effects.none
      )

    ReceiveAuthDetails (Just authDetails) ->
      Debug.log
        "success"
        ( { model | authState = AuthDone }
        , Effects.none
        )

    ReceiveAuthDetails Nothing ->
      Debug.log
        "here"
        ( { model | authState = AuthErrored }
        , Effects.none
        )

    -- TODO: handle error states here.
    otherwise ->
      ( model
      , Effects.none
      )


isValidState : Model -> String -> Bool
isValidState model state =
  case Dict.get "state" model.receivedDetails of
    Nothing ->
      False

    Just state' ->
      state == state'



-- View


view : Signal.Address Action -> Model -> Html
view address model =
  case model.authState of
    AuthLoading ->
      h3 [] [ text "Loading..." ]

    AuthErrored ->
      h3 [] [ text "Error loading, please try again" ]

    AuthDone ->
      h3 [] [ text "Loaded." ]



-- Effects


getStateFromStorage : Effects Action
getStateFromStorage =
  Storage.getItem Mondo.mondoOAuthStateKey Json.Decode.string
    |> Task.toMaybe
    |> Task.map LoadedState
    |> Effects.task


getAuthToken : Model -> Effects Action
getAuthToken model =
  let
    redirectUrl =
      Erl.appendPathSegments [ "receive" ] model.baseUrl

    code =
      Maybe.withDefault "" (Dict.get "code" model.receivedDetails)
  in
    Mondo.exchangeAuthCode code redirectUrl
      |> Task.map ReceiveAuthDetails
      |> Effects.task
