module Routes where

import RouteParser exposing (..)

type Route
    = Login
    | Home
    | NotFound
    | EmptyRoute

routeParsers : List (Matcher Route)
routeParsers =
    [ static Login "/"
    , static Home "/account"
    , static NotFound "/404"
    ]

decode : String -> Route
decode path =
  RouteParser.match routeParsers path
    |> Maybe.withDefault NotFound

encode : Route -> String
encode route =
    case route of
        Login -> "/"
        Home -> "/account"
        NotFound -> "/404"
        EmptyRoute -> "/404"
