module CounterPair where

import Html exposing (..)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)
import String

import Counter

-- Model

type alias Model =
    { topCounter : Counter.Model
    , bottomCounter: Counter.Model
    }

init : Int -> Int -> Model
init top bottom =
    { topCounter = Counter.init top
    , bottomCounter = Counter.init bottom
    }

-- Action

type Action
    = Reset
    | Top Counter.Action
    | Bottom Counter.Action

update : Action -> Model -> Model
update action model =
    case action of
        Reset -> init 0 0
        Top act ->
            { model |
                topCounter = Counter.update act model.topCounter
            }
        Bottom act ->
            { model |
                bottomCounter = Counter.update act model.bottomCounter
            }

-- View

view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ Counter.view (Signal.forwardTo address Top) model.topCounter
        , Counter.view (Signal.forwardTo address Bottom) model.bottomCounter
        , button [ onClick address Reset ] [ text "RESET" ]
        ]
