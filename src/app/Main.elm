import Debug exposing (log)
import Html exposing (..)
import Task
import StartApp
import Effects exposing (Never, Effects)
import TransitRouter exposing (..)

import Routes exposing (..)

import Login
import GifViewer

-- Global Model
type alias Model = WithRoute Routes.Route
    { loginModel : Login.Model
    , gifViewerModel : GifViewer.Model
    }

initialModel : Model
initialModel =
    { transitRouter = TransitRouter.empty Routes.EmptyRoute
    , loginModel = Login.init
    , gifViewerModel = GifViewer.init "funny cats"
    }

-- Global Action
type Action
    = NoOp
    | LoginAction Login.Action
    | GifViewerAction GifViewer.Action
    | RouterAction (TransitRouter.Action Routes.Route)

actions : Signal Action
actions =
    Signal.map RouterAction TransitRouter.actions

-- Global Routing
mountRoute : Route -> Route -> Model -> (Model, Effects Action)
mountRoute previous route model =
    case route of
        NotFound -> noUpdate model
        EmptyRoute -> noUpdate model

        Login -> noUpdate model

        Home ->
            (model, Effects.none)


noUpdate = (flip (,)) Effects.none

routerConfig : TransitRouter.Config Routes.Route Action Model
routerConfig =
    { mountRoute = mountRoute
    , getDurations = \_ _ _ -> (50, 50)
    , actionWrapper = RouterAction
    , routeDecoder = Routes.decode
    }

init : String -> (Model, Effects Action)
init initialPath =
  TransitRouter.init routerConfig initialPath initialModel

-- Global Update

update : Action -> Model -> (Model, Effects Action)
update action model =
    case action of
        NoOp ->
            (model, Effects.none)

        RouterAction routeAction ->
            TransitRouter.update routerConfig routeAction model

        LoginAction loginAction ->
            let (model', effects) =
                Login.update loginAction model.loginModel
            in
                ( { model | loginModel = model' }
                , Effects.map LoginAction effects
                )

        GifViewerAction gifAction ->
            let (model', effects) =
                GifViewer.update gifAction model.gifViewerModel
            in
                ( { model | gifViewerModel = model' }
                , Effects.map GifViewerAction effects
                )

-- Global View

view : Signal.Address Action -> Model -> Html
view address model =
    case (TransitRouter.getRoute model) of
        Login ->
            Login.view (Signal.forwardTo address LoginAction) model.loginModel

        Home ->
            GifViewer.view (Signal.forwardTo address GifViewerAction) model.gifViewerModel

        NotFound ->
            text "Not Found"

        EmptyRoute ->
            text "Application failed to initialise"

-- Start App

app =
    StartApp.start
        { init = init initialPath
        , update = update
        , view = view
        , inputs = [actions]
        }

main = app.html

port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks

port initialPath : String