module Views.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Routes


view : Html a
view =
    div [ class "view-not-found" ]
        [ div [ class "content" ]
            [ h1 [] [ text "404" ]
            , h2 [] [ text "Not Found" ]
            , a [ href (Routes.encode Routes.Login) ] [ text "Home" ]
            ]
        ]
