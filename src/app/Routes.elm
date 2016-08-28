module Routes exposing (..)

import Navigation
import UrlParser exposing (..)
import Json.Decode as Json
import Html
import Html.Events exposing (onWithOptions)
import Html.Attributes exposing (href)
import String


-- Routes


type Route
    = Login
    | ReceiveAuth
    | Home
    | NotFound
    | EmptyRoute


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ format Login (s "")
        , format ReceiveAuth (s "receive")
        , format Home (s "account")
        , format NotFound (s "404")
        ]


decodePath : String -> Result String Route
decodePath p =
    p
        |> String.dropLeft 1
        |> UrlParser.parse identity routeParser


decode : Navigation.Location -> Result String Route
decode location =
    decodePath location.pathname


decodePathOr404 : String -> Route
decodePathOr404 p =
    case (decodePath p) of
        Err _ ->
            NotFound

        Ok route ->
            route


decodeOr404 : Navigation.Location -> Route
decodeOr404 location =
    case (decode location) of
        Err _ ->
            NotFound

        Ok route ->
            route


encode : Route -> String
encode route =
    case route of
        Login ->
            "/"

        ReceiveAuth ->
            "/receive"

        Home ->
            "/account"

        NotFound ->
            "/404"

        EmptyRoute ->
            "/404"



-- Route Utils
-- redirect : Route -> Cmd ()
-- redirect route =
--     encode route
--         |> Signal.send TransitRouter.pushPathAddress
--         |> Cmd.task
--
--
-- linkTo : Route -> String -> Html.Html
-- linkTo route linkText =
--     let
--         path =
--             encode route
--     in
--         Html.a
--             [ href path, clickTo route ]
--             [ Html.text linkText ]
--
--
-- clickTo : Route -> Html.Attribute
-- clickTo route =
--     let
--         path =
--             encode route
--     in
--         onWithOptions
--             "click"
--             { stopPropagation = True, preventDefault = True }
--             Json.value
--             (\_ -> Signal.message TransitRouter.pushPathAddress path)
