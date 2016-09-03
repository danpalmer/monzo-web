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
import Api.Monzo as Monzo
import Api.Monzo.Models exposing (Account, Balance)


-- Model


type alias Model =
    { authDetails : Auth.AuthDetails
    , accounts : List ( Account, Balance )
    , error : Maybe Monzo.ApiError
    }


empty : Model
empty =
    { authDetails = Auth.emptyAuthDetails
    , accounts = []
    , error = Nothing
    }


init : Auth.AuthDetails -> Model
init authDetails =
    { authDetails = authDetails
    , accounts = []
    , error = Nothing
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
