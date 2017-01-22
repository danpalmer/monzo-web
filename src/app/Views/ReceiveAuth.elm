module Views.ReceiveAuth exposing (Model, init, Msg, update, view, mountedRoute)

import Prelude exposing (..)
import Html exposing (..)
import Task
import Routes
import Api.Monzo as Monzo
import Api.Monzo.Models exposing (ApiAuthDetails)
import Erl
import Dict exposing (Dict)
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
    | ReceiveApiAuthDetails ApiAuthDetails
    | ErrorExchangingApiAuthDetails Monzo.ApiError
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

        Just state_ ->
            state == state_



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
        |> Task.attempt (resultDetailToMsg ErrorPersistingApiAuthDetails PersistedApiAuthDetails)


getStateFromStorage : Cmd Msg
getStateFromStorage =
    LocalStorage.get Settings.monzoOAuthStateKey
        |> Task.attempt (resultDetailToMsg ErrorLoadingState LoadedState)


getAuthToken : Model -> Cmd Msg
getAuthToken model =
    let
        redirectUrl =
            Erl.appendPathSegments [ "receive" ] model.baseUrl

        code =
            Maybe.withDefault "" (Dict.get "code" model.receivedDetails)
    in
        Monzo.exchangeAuthCode code redirectUrl
            |> Task.attempt
                (resultDetailToMsg
                    ErrorExchangingApiAuthDetails
                    ReceiveApiAuthDetails
                )
