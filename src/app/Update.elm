module Update exposing (Msg(..), update)

import Routes
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
            if (Auth.expired authDetails model.flags.startTime) then
                ( model, Routes.navigate Routes.Login )
            else
                ( { model | accountModel = Account.init authDetails }
                , Routes.navigate Routes.Account
                )

        FailedToReadPersistedAuth _ ->
            ( model, Routes.navigate Routes.Login )

        otherwise ->
            ( model, Cmd.none )
