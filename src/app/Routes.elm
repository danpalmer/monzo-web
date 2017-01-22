module Routes exposing (..)

import Navigation
import UrlParser exposing (..)
import Html
import Html.Events exposing (onWithOptions)
import Html.Attributes exposing (href)
import Debug


-- Routes


type Route
    = Home
    | Login
    | ReceiveAuth
    | Account
    | NotFound


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ UrlParser.map Home (s "")
        , UrlParser.map Login (s "login")
        , UrlParser.map ReceiveAuth (s "receive")
        , UrlParser.map Account (s "account")
        , UrlParser.map NotFound (s "404")
        ]


decode : Navigation.Location -> Maybe Route
decode loc =
    Debug.log "decode" (UrlParser.parsePath routeParser loc)


decodeOr404 : Navigation.Location -> Route
decodeOr404 location =
    case (decode location) of
        Nothing ->
            NotFound

        Just route ->
            route


encode : Route -> String
encode route =
    case route of
        Home ->
            "/"

        Login ->
            "/login"

        ReceiveAuth ->
            "/receive"

        Account ->
            "/account"

        NotFound ->
            "/404"


routeOr404 : Maybe Route -> Route
routeOr404 result =
    case result of
        Just route ->
            route

        Nothing ->
            NotFound


navigate : Route -> Cmd msg
navigate route =
    Navigation.newUrl (encode route)



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
