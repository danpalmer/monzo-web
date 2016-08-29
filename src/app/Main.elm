module Main exposing (..)

import Navigation
import Html exposing (..)
import Html.App
import Html.Attributes exposing (style, class)
import Task
import Routes
import Views.Login as Login
import Views.ReceiveAuth as ReceiveAuth
import Views.Account as Account
import Utils.Auth as Auth
import Api.Mondo as Mondo
import Erl
import Dict exposing (Dict)
import Prelude exposing (parseSearchString)


type alias Flags =
    { initialPath : String
    , initialSeed : Int
    , startTime : Int
    , baseUrl : String
    , query : String
    }


main =
    Navigation.programWithFlags (Navigation.makeParser Routes.decode)
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }



-- Global Model


type alias Model =
    { currentRoute : Routes.Route
    , loginModel : Login.Model
    , receiveAuthModel : ReceiveAuth.Model
    , accountModel : Account.Model
    , flags : Flags
    }


initialModel : Flags -> Model
initialModel flags =
    let
        baseUrl =
            Erl.parse flags.baseUrl

        params =
            (parameters flags.query)
    in
        { currentRoute = Routes.decodePathOr404 flags.initialPath
        , loginModel = Login.init flags.initialSeed baseUrl
        , receiveAuthModel = ReceiveAuth.init params baseUrl flags.startTime
        , accountModel = Account.empty
        , flags = flags
        }


init : Flags -> Result String Routes.Route -> ( Model, Cmd Msg )
init flags result =
    let
        ( model, cmd ) =
            urlUpdate result (initialModel flags)
    in
        model ! [ getAuthDetailsFromStorage model.flags.startTime, cmd ]



-- Update


type Msg
    = NoOp
    | ReadPersistedAuth Auth.AuthDetails
    | FailedToReadPersistedAuth String
    | LoginMsg Login.Msg
    | ReceiveAuthMsg ReceiveAuth.Msg
    | AccountMsg Account.Msg



-- Global Update


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



-- Global View


contentView : Model -> Html Msg
contentView model =
    case model.currentRoute of
        Routes.Home ->
            text "home..."

        Routes.Login ->
            Html.App.map LoginMsg (Login.view model.loginModel)

        Routes.ReceiveAuth ->
            Html.App.map ReceiveAuthMsg (ReceiveAuth.view model.receiveAuthModel)

        Routes.Account ->
            Html.App.map AccountMsg (Account.view model.accountModel)

        Routes.NotFound ->
            text "Not Found"


view : Model -> Html Msg
view model =
    div
        [ class "container-fluid" ]
        [ div
            [ class "content"
            ]
            [ contentView model ]
        ]


parameters : String -> Dict String String
parameters query =
    let
        maybeParams =
            parseSearchString query
    in
        Maybe.withDefault Dict.empty maybeParams



-- Cmd


getAuthDetailsFromStorage : Int -> Cmd Msg
getAuthDetailsFromStorage appStartTime =
    Auth.getAuthDetailsFromStorage appStartTime
        |> Task.perform FailedToReadPersistedAuth ReadPersistedAuth



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
