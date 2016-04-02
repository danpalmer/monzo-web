module Main (..) where

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Task
import StartApp
import Effects exposing (Never, Effects)
import TransitRouter exposing (..)
import TransitStyle
import Routes exposing (..)
import Views.Login as Login
import Views.GifViewer as GifViewer
import Views.ReceiveAuth as ReceiveAuth
import Api.Mondo as Mondo
import Erl
import Dict exposing (Dict)
import Prelude exposing (parseSearchString)


-- Global Model


type alias Model =
  WithRoute
    Routes.Route
    { loginModel : Login.Model
    , receiveAuthModel : ReceiveAuth.Model
    , gifViewerModel : GifViewer.Model
    }


initialModel : Model
initialModel =
  { transitRouter = TransitRouter.empty Routes.EmptyRoute
  , loginModel = Login.init initialSeed (Erl.parse baseUrl)
  , receiveAuthModel = ReceiveAuth.init parameters
  , gifViewerModel = GifViewer.init "funny cats"
  }



-- Global Action


type Action
  = NoOp
  | LoginAction Login.Action
  | ReceiveAuthAction ReceiveAuth.Action
  | GifViewerAction GifViewer.Action
  | RouterAction (TransitRouter.Action Routes.Route)


actions : Signal Action
actions =
  Signal.map RouterAction TransitRouter.actions



-- Global Routing


mountRoute : Route -> Route -> Model -> ( Model, Effects Action )
mountRoute previous route model =
  case route of
    Login ->
      let
        ( model', effects' ) =
          Login.mountedRoute model.loginModel
      in
        ( { model | loginModel = model' }
        , Effects.map LoginAction effects'
        )

    ReceiveAuth ->
      let
        ( model', effects' ) =
          ReceiveAuth.mountedRoute model.receiveAuthModel
      in
        ( { model | receiveAuthModel = model' }
        , Effects.map ReceiveAuthAction effects'
        )

    otherwise ->
      noUpdate model


noUpdate : a -> ( a, Effects Action )
noUpdate =
  (flip (,)) Effects.none


routerConfig : TransitRouter.Config Routes.Route Action Model
routerConfig =
  { mountRoute = mountRoute
  , getDurations = \_ _ _ -> ( 50, 50 )
  , actionWrapper = RouterAction
  , routeDecoder = Routes.decode
  }


init : String -> ( Model, Effects Action )
init initialPath =
  TransitRouter.init routerConfig initialPath initialModel



-- Global Update


update : Action -> Model -> ( Model, Effects Action )
update action model =
  case action of
    RouterAction routeAction ->
      TransitRouter.update routerConfig routeAction model

    ReceiveAuthAction receiveAuthAction ->
      let
        ( model', effects ) =
          ReceiveAuth.update receiveAuthAction model.receiveAuthModel
      in
        ( { model | receiveAuthModel = model' }, Effects.map ReceiveAuthAction effects )

    GifViewerAction gifAction ->
      let
        ( model', effects ) =
          GifViewer.update gifAction model.gifViewerModel
      in
        ( { model | gifViewerModel = model' }
        , Effects.map GifViewerAction effects
        )

    otherwise ->
      ( model, Effects.none )



-- Global View


contentView : Signal.Address Action -> Model -> Html
contentView address model =
  case (TransitRouter.getRoute model) of
    Login ->
      Login.view (Signal.forwardTo address LoginAction) model.loginModel

    Home ->
      GifViewer.view (Signal.forwardTo address GifViewerAction) model.gifViewerModel

    NotFound ->
      text "Not Found"

    EmptyRoute ->
      text "Application failed to initialise"

    ReceiveAuth ->
      ReceiveAuth.view (Signal.forwardTo address ReceiveAuthAction) model.receiveAuthModel


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "container-fluid" ]
    [ div
        [ class "content"
        , style (TransitStyle.fadeSlideLeft 100 (getTransition model))
        ]
        [ contentView address model ]
    ]



-- Start App


app =
  StartApp.start
    { init = init initialPath
    , update = update
    , view = view
    , inputs = [ actions ]
    }


main =
  app.html



-- Ports


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


port initialPath : String
port initialSeed : Int
port baseUrl : String
port redirect : Signal String
port redirect =
  redirectMailbox.signal


redirectMailbox =
  Signal.mailbox ""


port query : String
parameters : Dict String String
parameters =
  let
    maybeParams =
      parseSearchString query
  in
    Maybe.withDefault Dict.empty maybeParams
