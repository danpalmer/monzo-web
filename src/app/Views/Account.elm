module Views.Account
    exposing
        ( Model
        , Msg
        , empty
        , init
        , view
        , update
        , mountedRoute
        )

import Platform.Cmd
import Html exposing (..)
import Utils.Auth as Auth


-- Model


type alias Model =
    { authDetails : Auth.AuthDetails
    }


empty : Model
empty =
    { authDetails = Auth.emptyAuthDetails
    }


init : Auth.AuthDetails -> Model
init authDetails =
    { authDetails = authDetails
    }


mountedRoute : Model -> ( Model, Cmd Msg )
mountedRoute model =
    ( model, Cmd.none )



-- Update


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [] [ h1 [] [ text model.authDetails.userID ] ]
