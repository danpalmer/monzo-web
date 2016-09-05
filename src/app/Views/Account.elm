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
import Html.Attributes exposing (class)
import Utils.Auth as Auth
import Api.Monzo as Monzo
import Api.Monzo.Models exposing (Account, Balance)
import Components.AccountSummary as AccountSummary
import Prelude exposing (join3)


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
            { model | error = Nothing }
                ! (getBalances model.authDetails accounts)

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


getBalances : Auth.AuthDetails -> List Account -> List (Cmd Msg)
getBalances authDetails accounts =
    (List.map (getBalance authDetails) accounts)


getBalance : Auth.AuthDetails -> Account -> Cmd Msg
getBalance authDetails account =
    Monzo.getBalance authDetails account
        |> Task.perform Error (ReceiveBalance account)



-- View


view : Model -> Html Msg
view model =
    div [ class "view-account" ]
        [ div [ class "balances" ]
            (join3
                [ viewHeader model ]
                (viewBalances model)
                [ (viewLogout model)
                ]
            )
        , div [ class "transactions" ] []
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "header" ] []


viewBalances : Model -> List (Html Msg)
viewBalances model =
    List.map (\( x, y ) -> AccountSummary.view x y) model.accounts


viewLogout : Model -> Html Msg
viewLogout model =
    div [ class "logout" ]
        [ button [] []
        ]
