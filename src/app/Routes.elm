module Routes (..) where

import Json.Decode as Json
import Signal
import RouteParser exposing (..)
import TransitRouter
import Html
import Html.Events exposing (onWithOptions)
import Html.Attributes exposing (href)


-- Routes


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
    Login ->
      "/"

    Home ->
      "/account"

    NotFound ->
      "/404"

    EmptyRoute ->
      "/404"



-- Route Utils


linkTo : Route -> String -> Html.Html
linkTo route linkText =
  let
    path =
      encode route
  in
    Html.a
      [ href path, clickTo route ]
      [ Html.text linkText ]


clickTo : Route -> Html.Attribute
clickTo route =
  let
    path =
      encode route
  in
    onWithOptions
      "click"
      { stopPropagation = True, preventDefault = True }
      Json.value
      (\_ -> Signal.message TransitRouter.pushPathAddress path)
