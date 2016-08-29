module Views.Login exposing (Model, init, Msg, view, update, mountedRoute)

import Random exposing (initialSeed, Seed, generate)
import Random.String exposing (string)
import Random.Char exposing (english)
import Platform.Cmd
import Html exposing (..)
import Html.Attributes exposing (style, class, href)
import Http
import Json.Decode as JD
import Json.Decode as JD exposing ((:=))
import Task
import Settings
import Routes
import Navigation
import Api.Mondo as Mondo
import Erl
import Prelude exposing (..)
import LocalStorage
import Utils.Auth as Auth
import Debug


-- Model


type ReadyState
    = Preparing
    | Ready
    | Errored


type alias Model =
    { randomStateSeed : Seed
    , baseUrl : Erl.Url
    , redirectUrl : Erl.Url
    , readyState : ReadyState
    }


init : Int -> Erl.Url -> Model
init seed baseUrl =
    { randomStateSeed = initialSeed seed
    , baseUrl = baseUrl
    , redirectUrl = Erl.new
    , readyState = Preparing
    }


mountedRoute : Model -> ( Model, Cmd Msg )
mountedRoute model =
    ( model, generate GeneratedState (string 20 english) )



-- Update


type Msg
    = GeneratedState String
    | StoredState ()
    | FailedToStoreState ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GeneratedState state ->
            let
                returnUrl =
                    Erl.appendPathSegments [ "receive" ] model.baseUrl

                url =
                    Mondo.loginUrl state returnUrl
            in
                ( { model | redirectUrl = url }
                , setStateInStorage state
                )

        StoredState _ ->
            ( { model | readyState = Ready }, Cmd.none )

        FailedToStoreState _ ->
            ( { model | readyState = Errored }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    case model.readyState of
        Preparing ->
            div [] [ h1 [] [ text "Loading..." ] ]

        Ready ->
            div
                [ style [ "width" => "200px" ] ]
                [ a [ href (Erl.toString model.redirectUrl) ] [ text "Login" ]
                ]

        Errored ->
            div [] [ h1 [] [ text "Error" ] ]



-- Cmd


setStateInStorage : String -> Cmd Msg
setStateInStorage state =
    LocalStorage.set Settings.mondoOAuthStateKey state
        |> Task.perform FailedToStoreState StoredState
