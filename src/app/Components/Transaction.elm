module Components.Transaction exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Api.Monzo.Models exposing (Transaction, Currency(..))


view : Transaction -> Html a
view transaction =
    div [ class "component-transaction" ] [ text "transaction" ]
