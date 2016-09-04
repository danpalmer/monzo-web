module Components.Balance exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Api.Monzo.Models exposing (Account, Balance)


view : Account -> Balance -> Html a
view account balance =
    div [ class "component-balance" ]
        [ div [ class "balance" ] [ text "£10.00" ]
        , div [ class "spend-today" ] [ text "£2.50" ]
        ]
