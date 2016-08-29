module Views.ReceiveAuth exposing (Model, init, Msg, update, view, mountedRoute)

import Random exposing (initialSeed, Seed)
import Html exposing (..)
import Html.Attributes exposing (style, class, href)
import Http
import HttpBuilder
import Json.Encode as JE
import Task
import Routes
import Api.Mondo as Mondo
import Erl
import Prelude exposing (..)
import Dict exposing (Dict)
import String
import Navigation
import Settings
import LocalStorage
import Utils.Auth as Auth


-- Model


type AuthState
    = AuthLoading
    | AuthErrored
    | AuthDone


type alias Model =
    { receivedDetails : Dict String String
    , authState : AuthState
    , baseUrl : Erl.Url
    , appStartTime : Int
    }


init : Dict String String -> Erl.Url -> Int -> Model
init receivedDetails baseUrl appStartTime =
    { receivedDetails = receivedDetails
    , authState = AuthLoading
    , baseUrl = baseUrl
    , appStartTime = appStartTime
    }


mountedRoute : Model -> ( Model, Cmd Msg )
mountedRoute model =
    ( model, getStateFromStorage )



-- Update


type Msg
    = LoadedState String
    | ErrorLoadingState LocalStorage.Error
    | ReceiveApiAuthDetails Mondo.ApiAuthDetails
    | ErrorExchangingApiAuthDetails (HttpBuilder.Error String)
    | PersistedApiAuthDetails ()
    | ErrorPersistingApiAuthDetails LocalStorage.Error


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedState state ->
            if (isValidState model state) then
                ( { model | authState = AuthDone }
                , getAuthToken model
                )
            else
                ( { model | authState = AuthErrored }
                , Cmd.none
                )

        ErrorLoadingState _ ->
            ( { model | authState = AuthErrored }
            , Cmd.none
            )

        ReceiveApiAuthDetails authDetails ->
            ( { model | authState = AuthDone }
            , setAuthDetailsInStorage
                (Auth.apiAuthDetailsToAuthDetails authDetails model.appStartTime)
            )

        ErrorExchangingApiAuthDetails _ ->
            ( { model | authState = AuthErrored }
            , Cmd.none
            )

        PersistedApiAuthDetails _ ->
            ( model, Navigation.newUrl (Routes.encode Routes.Account) )

        -- TODO: handle error states here.
        otherwise ->
            ( model
            , Cmd.none
            )


isValidState : Model -> String -> Bool
isValidState model state =
    case Dict.get "state" model.receivedDetails of
        Nothing ->
            False

        Just state' ->
            state == state'



-- View


view : Model -> Html Msg
view model =
    case model.authState of
        AuthLoading ->
            h3 [] [ text "Loading..." ]

        AuthErrored ->
            h3 [] [ text "Error loading, please try again" ]

        AuthDone ->
            h3 [] [ text "Loaded." ]



-- Cmd


setAuthDetailsInStorage : Auth.AuthDetails -> Cmd Msg
setAuthDetailsInStorage authDetails =
    Auth.setAuthDetailsInStorage authDetails
        |> Task.perform ErrorPersistingApiAuthDetails PersistedApiAuthDetails


getStateFromStorage : Cmd Msg
getStateFromStorage =
    LocalStorage.get Settings.mondoOAuthStateKey
        |> Task.perform ErrorLoadingState LoadedState


getAuthToken : Model -> Cmd Msg
getAuthToken model =
    let
        redirectUrl =
            Erl.appendPathSegments [ "receive" ] model.baseUrl

        code =
            Maybe.withDefault "" (Dict.get "code" model.receivedDetails)
    in
        Mondo.exchangeAuthCode code redirectUrl
            |> Task.perform ErrorExchangingApiAuthDetails ReceiveApiAuthDetails
