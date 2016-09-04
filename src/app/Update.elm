module Update exposing (Msg(..), update)

import Routes
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "Update" msg of
        LoginMsg loginMsg ->
            let
                ( model', msg ) =
                    Login.update loginMsg model.loginModel
            in
                ( { model | loginModel = model' }, Cmd.map LoginMsg msg )

        ReceiveAuthMsg receiveAuthMsg ->
            let
                ( model', msg ) =
                    ReceiveAuth.update receiveAuthMsg model.receiveAuthModel
            in
                ( { model | receiveAuthModel = model' }, Cmd.map ReceiveAuthMsg msg )

        AccountMsg accountMsg ->
            let
                ( model', msg ) =
                    Account.update accountMsg model.accountModel
            in
                ( { model | accountModel = model' }, Cmd.map AccountMsg msg )

        ReadPersistedAuth authDetails ->
            authLoaded authDetails model

        FailedToReadPersistedAuth _ ->
            ( model, Routes.navigate Routes.Login )

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

        model' =
            { model | accountModel = Account.init authDetails }

        atHome =
            model.currentRoute == Routes.Home
    in
        if (authRequired && authExpired) then
            -- If we don't have the auth we need, redirect to Login
            ( model', Routes.navigate Routes.Login )
        else if (atHome && (not authExpired)) then
            -- If we're on the landing page, and have auth, go to Account
            model'
                ! [ Routes.navigate Routes.Account
                  , sendMsg (AccountMsg Account.AuthLoaded)
                  ]
        else if (atHome && authExpired) then
            -- If we're on the landing page, and have no auth, go to Login
            ( model', Routes.navigate Routes.Login )
        else
            -- We're on a different route, so just stay there and update the model
            ( model', sendMsg (AccountMsg Account.AuthLoaded) )
