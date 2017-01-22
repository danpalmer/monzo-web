module Update exposing (Msg(..), update, urlUpdate)

import Routes
import Task
import Navigation exposing (Location)
import Prelude exposing (..)
import Model exposing (Model)
import Views.Login as Login
import Views.ReceiveAuth as ReceiveAuth
import Views.Account as Account
import Utils.Auth as Auth


type Msg
    = NoOp
    | ReadPersistedAuth Auth.AuthDetails
    | FailedToReadPersistedAuth String
    | LoginMsg Login.Msg
    | ReceiveAuthMsg ReceiveAuth.Msg
    | AccountMsg Account.Msg
    | NavigateMsg Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Update" msg of
        LoginMsg loginMsg ->
            let
                ( model_, msg ) =
                    Login.update loginMsg model.loginModel
            in
                ( { model | loginModel = model_ }, Cmd.map LoginMsg msg )

        ReceiveAuthMsg receiveAuthMsg ->
            let
                ( model_, msg ) =
                    ReceiveAuth.update receiveAuthMsg model.receiveAuthModel
            in
                ( { model | receiveAuthModel = model_ }, Cmd.map ReceiveAuthMsg msg )

        AccountMsg accountMsg ->
            let
                ( model_, msg ) =
                    Account.update accountMsg model.accountModel
            in
                ( { model | accountModel = model_ }, Cmd.map AccountMsg msg )

        ReadPersistedAuth authDetails ->
            authLoaded authDetails model

        FailedToReadPersistedAuth _ ->
            ( model, Routes.navigate Routes.Login )

        NavigateMsg loc ->
            urlUpdate (Routes.decode loc) model

        otherwise ->
            ( model, Cmd.none )


urlUpdate : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
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
                    ( model_, msg ) =
                        Login.mountedRoute model.loginModel
                in
                    ( { model | loginModel = model_ }, Cmd.map LoginMsg msg )

            Routes.ReceiveAuth ->
                let
                    ( model_, msg ) =
                        ReceiveAuth.mountedRoute model.receiveAuthModel
                in
                    ( { model | receiveAuthModel = model_ }, Cmd.map ReceiveAuthMsg msg )

            Routes.Account ->
                let
                    ( model_, msg ) =
                        Account.mountedRoute model.accountModel
                in
                    { model | accountModel = model_ }
                        ! [ Cmd.map AccountMsg msg
                          , getAuthDetailsFromStorage model.flags.startTime
                          ]

            otherwise ->
                ( model, Cmd.none )


authLoaded : Auth.AuthDetails -> Model -> ( Model, Cmd Msg )
authLoaded authDetails model =
    let
        authRequiredRoutes =
            [ Routes.Account ]

        authRequired =
            List.member model.currentRoute authRequiredRoutes

        authExpired =
            Auth.expired authDetails model.flags.startTime

        model_ =
            { model | accountModel = Account.init authDetails }

        atHome =
            model.currentRoute == Routes.Home
    in
        if (authRequired && authExpired) then
            -- If we don't have the auth we need, redirect to Login
            ( model_, Routes.navigate Routes.Login )
        else if (atHome && (not authExpired)) then
            -- If we're on the landing page, and have auth, go to Account
            model_
                ! [ Routes.navigate Routes.Account
                  , sendMsg (AccountMsg Account.AuthLoaded)
                  ]
        else if (atHome && authExpired) then
            -- If we're on the landing page, and have no auth, go to Login
            ( model_, Routes.navigate Routes.Login )
        else
            -- We're on a different route, so just stay there and update the model
            ( model_, sendMsg (AccountMsg Account.AuthLoaded) )



-- Cmd


getAuthDetailsFromStorage : Int -> Cmd Msg
getAuthDetailsFromStorage appStartTime =
    Auth.getAuthDetailsFromStorage appStartTime
        |> Task.attempt
            (resultDetailToMsg FailedToReadPersistedAuth ReadPersistedAuth)
