module Views.Login exposing (Model, init, Msg, view, update, mountedRoute)

import Random exposing (initialSeed, Seed, generate)
import Random.String exposing (string)
import Random.Char exposing (english)
import Platform.Cmd
import Html exposing (..)
import Html.Attributes exposing (style, class, href, disabled)
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
            viewContent model False Nothing

        Ready ->
            viewContent model True Nothing

        Errored ->
            viewContent model False (Just "Error, please contact support")


viewContent : Model -> Bool -> Maybe String -> Html Msg
viewContent model loginEnabled error =
    let
        loginElement =
            if loginEnabled then
                a
            else
                span

        errorElement =
            case error of
                Nothing ->
                    []

                Just err ->
                    [ p [ class "error" ] [ text err ] ]
    in
        div [ class "view-login" ]
            [ div [ class "content" ]
                (List.append
                    [ loginElement
                        [ class "login"
                        , href (Erl.toString model.redirectUrl)
                        , disabled (not loginEnabled)
                        ]
                        [ text "Login with Mondo" ]
                    ]
                    errorElement
                )
            ]



-- Cmd


setStateInStorage : String -> Cmd Msg
setStateInStorage state =
    LocalStorage.set Settings.mondoOAuthStateKey state
        |> Task.perform FailedToStoreState StoredState
