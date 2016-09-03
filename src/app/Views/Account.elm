module Views.Account
    exposing
        ( Model
        , Msg
        , empty
        , init
        , view
        , update
        , mountedRoute
        , Msg(..)
        )

import Task
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
    if (Auth.isEmpty model.authDetails) then
        ( model, Cmd.none )
    else
        ( model, getAccounts model.authDetails )



-- Update


type Msg
    = AuthLoaded
    | ReceiveAccounts (List Account)
    | ReceiveBalance Account Balance
    | Error Monzo.ApiError


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AuthLoaded ->
            ( model, getAccounts model.authDetails )

        ReceiveAccounts accounts ->
            ( { model | error = Nothing }, Cmd.none )

        ReceiveBalance account balance ->
            ( { model
                | accounts = sortAccounts (( account, balance ) :: model.accounts)
                , error = Nothing
              }
            , Cmd.none
            )

        Error error ->
            ( { model | error = Just error }, Cmd.none )


sortAccounts : List ( Account, Balance ) -> List ( Account, Balance )
sortAccounts =
    identity



-- Actions


getAccounts : Auth.AuthDetails -> Cmd Msg
getAccounts authDetails =
    Monzo.getAccounts authDetails
        |> Task.perform Error ReceiveAccounts



-- View


view : Model -> Html Msg
view model =
    div [] [ h1 [] [ text model.authDetails.userID ] ]
