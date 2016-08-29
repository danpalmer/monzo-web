module Views.Loading exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Components.Spinner


view : Html a
view =
    div [ class "view-loading" ]
        [ Components.Spinner.view
        ]
