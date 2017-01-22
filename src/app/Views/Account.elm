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
import Date.Extra as DE
import Dict exposing (Dict)
import Platform.Cmd
import Html exposing (..)
import Html.Attributes exposing (class)
import Utils.Auth as Auth
import Api.Monzo as Monzo
import Api.Monzo.Models exposing (Account, Balance, Transaction)
import Components.Error as ErrorComponent
import Components.Spinner as Spinner
import Components.AccountSummary as AccountSummary
import Components.TransactionsList as TransactionsList
import Prelude exposing (join3, resultDetailToMsg)


-- Model


type alias Model =
    { authDetails : Auth.AuthDetails
    , accounts : List ( Account, Balance )
    , transactions : Dict String (List Transaction)
    , error : Maybe Monzo.ApiError
    , selectedAccount : Maybe Account
    }


empty : Model
empty =
    { authDetails = Auth.emptyAuthDetails
    , accounts = []
    , transactions = Dict.empty
    , error = Nothing
    , selectedAccount = Nothing
    }


init : Auth.AuthDetails -> Model
init authDetails =
    { authDetails = authDetails
    , accounts = []
    , transactions = Dict.empty
    , error = Nothing
    , selectedAccount = Nothing
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
    | ReceiveTransactions Account (List Transaction)
    | Error Monzo.ApiError


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AuthLoaded ->
            ( model, getAccounts model.authDetails )

        ReceiveAccounts accounts ->
            { model | error = Nothing }
                ! ((getBalances model.authDetails accounts)
                    ++ (getTransactionsForAccounts model.authDetails accounts)
                  )

        ReceiveBalance account balance ->
            let
                -- TODO: Only insert if not already present
                newAccounts =
                    sortAccounts (( account, balance ) :: model.accounts)

                firstAccount =
                    Maybe.map Tuple.first (List.head newAccounts)
            in
                ( { model
                    | accounts = newAccounts
                    , selectedAccount = firstAccount
                    , error = Nothing
                  }
                , Cmd.none
                )

        ReceiveTransactions account transactions ->
            let
                transactions_ =
                    sortTransactions transactions
            in
                ( { model
                    | transactions = Dict.insert account.id transactions_ model.transactions
                    , error = Nothing
                  }
                , Cmd.none
                )

        Error error ->
            ( { model | error = Just error }, Cmd.none )


sortAccounts : List ( Account, Balance ) -> List ( Account, Balance )
sortAccounts =
    List.sortBy (\( a, _ ) -> a.id)


sortTransactions : List Transaction -> List Transaction
sortTransactions =
    List.sortWith (\a b -> DE.compare b.created a.created)



-- Actions


getAccounts : Auth.AuthDetails -> Cmd Msg
getAccounts authDetails =
    Monzo.getAccounts authDetails
        |> Task.attempt (resultDetailToMsg Error ReceiveAccounts)


getBalances : Auth.AuthDetails -> List Account -> List (Cmd Msg)
getBalances authDetails accounts =
    (List.map (getBalance authDetails) accounts)


getBalance : Auth.AuthDetails -> Account -> Cmd Msg
getBalance authDetails account =
    Monzo.getBalance authDetails account
        |> Task.attempt (resultDetailToMsg Error (ReceiveBalance account))


getTransactionsForAccounts : Auth.AuthDetails -> List Account -> List (Cmd Msg)
getTransactionsForAccounts authDetails accounts =
    (List.map (getTransactionsForAccount authDetails) accounts)


getTransactionsForAccount : Auth.AuthDetails -> Account -> Cmd Msg
getTransactionsForAccount authDetails account =
    Monzo.getRecentTransactions authDetails account
        |> Task.attempt (resultDetailToMsg Error (ReceiveTransactions account))



-- View


view : Model -> Html Msg
view model =
    case model.error of
        Nothing ->
            div [ class "view-account" ]
                [ div [ class "balances" ]
                    (join3
                        [ viewHeader model ]
                        (viewBalances model)
                        [ (viewLogout model)
                        ]
                    )
                , div [ class "transactions" ]
                    [ viewTransactions model
                    ]
                ]

        Just err ->
            ErrorComponent.view err


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


viewTransactions : Model -> Html Msg
viewTransactions model =
    let
        account =
            model.selectedAccount

        accountId =
            Maybe.map .id account

        transactions =
            Maybe.andThen (flip Dict.get model.transactions) accountId
    in
        case ( account, transactions ) of
            ( Just acc, Just txs ) ->
                TransactionsList.view acc txs

            ( Just acc, Nothing ) ->
                Spinner.view

            otherwise ->
                div [] [ text "No selected account" ]
