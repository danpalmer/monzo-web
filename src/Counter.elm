module Counter (Model, init, Action, update, view, viewWithRemoveButton, Context) where

import Html exposing (..)
import Html.Attributes exposing (attribute)
import Html.Events exposing (onClick)
import String

-- Model

type alias Model = Int

init : Int -> Model
init count = count

-- Update

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
    case action of
        Increment -> model + 1
        Decrement -> model - 1

-- View

class = attribute "class"

view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ button [ onClick address Decrement, class "minus" ] [ text "Subtract" ]
        , div [] [ text (toString model) ]
        , button [ onClick address Increment, class "plus" ] [ text "Add" ]
        ]

type alias Context =
    { actions: Signal.Address Action
    , remove: Signal.Address ()
    }

viewWithRemoveButton : Context -> Model -> Html
viewWithRemoveButton context model =
    div []
        [ button [ onClick context.actions Decrement ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick context.actions Increment ] [ text "+" ]
        , div [] []
        , button [ onClick context.remove () ] [ text "X" ]
        ]
