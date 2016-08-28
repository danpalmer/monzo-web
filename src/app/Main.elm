module Main exposing (..)

import Navigation
import Html exposing (..)
import Html.App
import Html.Attributes exposing (style, class)
import Task
import Routes
import Views.Login as Login
import Views.ReceiveAuth as ReceiveAuth
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
        , flags = flags
        }


init : Flags -> Result String Routes.Route -> ( Model, Cmd Msg )
init flags result =
    urlUpdate result (initialModel flags)



-- Update


type Msg
    = NoOp
    | LoginMsg Login.Msg
    | ReceiveAuthMsg ReceiveAuth.Msg
    | Navigate Routes.Route



-- Global Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate route ->
            { model | currentRoute = route }
                ! [ Navigation.newUrl (Routes.encode route) ]

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

        otherwise ->
            ( model, Cmd.none )


urlUpdate : Result String Routes.Route -> Model -> ( Model, Cmd Msg )
urlUpdate result model =
    case result of
        Err str ->
            Debug.log str ( model, Cmd.none )

        Ok route ->
            case route of
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

                otherwise ->
                    ( model, Cmd.none )



-- Global View


contentView : Model -> Html Msg
contentView model =
    case model.currentRoute of
        Routes.Login ->
            Html.App.map LoginMsg (Login.view model.loginModel)

        Routes.ReceiveAuth ->
            Html.App.map ReceiveAuthMsg (ReceiveAuth.view model.receiveAuthModel)

        Routes.Home ->
            text "Home"

        Routes.NotFound ->
            text "Not Found"

        Routes.EmptyRoute ->
            text "Loading..."


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



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
