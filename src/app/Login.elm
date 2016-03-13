module Login (Model, init, Action, update, view) where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task

import Routes

-- Model

type alias Model = {}

init : Model
init = Model

-- Update

type Action
    = Login

update : Action -> Model -> (Model, Effects Action)
update msg model =
    case msg of
        Login ->
            ( model
            , Effects.none
            )

-- View

(=>) = (,)

view : Signal.Address Action -> Model -> Html
view address model =
    div [ style [ "width" => "200px" ] ]
        [ h2 [] [text "Page 1"]
        , button [Routes.clickTo Routes.Home] [text "Login Button"]
        , Routes.linkTo Routes.Home "Login Link"
        ]
