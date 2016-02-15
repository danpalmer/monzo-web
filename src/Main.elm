import Html exposing (..)
import Html.Attributes exposing (attribute)
import Html.Events exposing ( onClick )
import String

import StartApp.Simple exposing (start)

main =
    start { model = 0, view = view, update = update }

type alias Model = Int

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
    case action of
        Increment -> model + 1
        Decrement -> model - 1

view : Signal.Address Action -> Model -> Html
view address model =
    div []
        [ button [ onClick address Decrement, class "minus" ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick address Increment, class "plus" ] [ text "+" ]
        ]

class = attribute "class"
