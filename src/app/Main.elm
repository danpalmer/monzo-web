module Main exposing (..)

import Navigation exposing (Location)
import View exposing (view)
import Routes
import Update exposing (..)
import Model exposing (Model, Flags, initialModel)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags locationToMsg
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        model =
            (initialModel flags location)
    in
        urlUpdate (Routes.decode location) model


locationToMsg : Location -> Msg
locationToMsg =
    NavigateMsg



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
