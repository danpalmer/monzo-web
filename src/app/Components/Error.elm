module Components.Error exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Api.Monzo as Monzo


view : Monzo.ApiError -> Html a
view err =
    let
        ( errTitle, errDescription ) =
            Monzo.describeApiError err
    in
        div [ class "component-error" ]
            [ h1 [] [ text errTitle ]
            , h3 [] [ text errDescription ]
            ]
