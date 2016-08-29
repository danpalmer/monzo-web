module Main exposing (..)

import Html.App
import Task
import Navigation
import Dict exposing (Dict)
import Erl
import Routes
import Api.Mondo as Mondo
import View exposing (view)
import Update exposing (Msg(..), update)
import Model exposing (Model, Flags, initialModel)
import Views.Login as Login
import Views.ReceiveAuth as ReceiveAuth
import Views.Account as Account
import Utils.Auth as Auth


main =
    Navigation.programWithFlags (Navigation.makeParser Routes.decode)
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }


init : Flags -> Result String Routes.Route -> ( Model, Cmd Msg )
init flags result =
    let
        ( model, cmd ) =
            urlUpdate result (initialModel flags)
    in
        model ! [ getAuthDetailsFromStorage model.flags.startTime, cmd ]



-- Update


urlUpdate : Result String Routes.Route -> Model -> ( Model, Cmd Msg )
urlUpdate result m =
    let
        route =
            Routes.routeOr404 result

        model =
            { m | currentRoute = route }
    in
        case Debug.log "Navigating to" route of
            Routes.Home ->
                ( model, getAuthDetailsFromStorage model.flags.startTime )

            Routes.Login ->
                let
                    ( model', msg ) =
                        Login.mountedRoute model.loginModel
                in
                    ( { model | loginModel = model' }, Cmd.map LoginMsg msg )

            Routes.ReceiveAuth ->
                let
                    ( model', msg ) =
                        ReceiveAuth.mountedRoute model.receiveAuthModel
                in
                    ( { model | receiveAuthModel = model' }, Cmd.map ReceiveAuthMsg msg )

            Routes.Account ->
                let
                    ( model', msg ) =
                        Account.mountedRoute model.accountModel
                in
                    ( { model | accountModel = model' }, Cmd.map AccountMsg msg )

            otherwise ->
                ( model, Cmd.none )



-- Cmd


getAuthDetailsFromStorage : Int -> Cmd Msg
getAuthDetailsFromStorage appStartTime =
    Auth.getAuthDetailsFromStorage appStartTime
        |> Task.perform FailedToReadPersistedAuth ReadPersistedAuth



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
