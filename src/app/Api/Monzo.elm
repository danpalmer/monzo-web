module Api.Monzo exposing (..)

import Date exposing (Date)
import Dict
import Task exposing (..)
import Json.Decode exposing (Decoder)
import Erl
import HttpBuilder as H exposing (..)
import Settings
import Prelude exposing (..)
import Utils.Auth exposing (AuthDetails)
import Api.Monzo.Models exposing (..)
import Api.Monzo.Decoder exposing (..)
import Api.Monzo.Util exposing (formatDate)


loginUrl : String -> Erl.Url -> Erl.Url
loginUrl state redirectUrl =
    let
        url =
            Erl.parse "https://auth.getmondo.co.uk/"
    in
        { url
            | query =
                Dict.fromList
                    [ "client_id" => Settings.monzoClientID
                    , "redirect_uri" => Erl.toString redirectUrl
                    , "response_type" => "code"
                    , "state" => state
                    ]
        }


exchangeAuthCode : String -> Erl.Url -> Task (Error String) ApiAuthDetails
exchangeAuthCode code redirectUrl =
    let
        data =
            [ "grant_type" => "authorization_code"
            , "client_id" => Settings.monzoClientID
            , "client_secret" => Settings.monzoClientSecret
            , "redirect_uri" => Erl.toString redirectUrl
            , "code" => code
            ]
    in
        post "https://api.getmondo.co.uk/oauth2/token"
            |> withUrlEncodedBody data
            |> withHeader "Content-type" "application/x-www-form-urlencoded"
            |> send (jsonReader decodeApiAuthDetails) stringReader
            |> Task.map (\response -> response.data)


getAccounts : AuthDetails -> Task (Error String) (List Account)
getAccounts authDetails =
    monzoGet "https://api.getmondo.co.uk/accounts" authDetails decodeAccountList []


getBalance : AuthDetails -> Account -> Task (Error String) Balance
getBalance authDetails account =
    monzoGet "https://api.getmondo.co.uk/accounts"
        authDetails
        decodeBalance
        [ "account_id" => account.id
        ]


getRecentTransactions : AuthDetails -> Account -> Task (Error String) (List Transaction)
getRecentTransactions authDetails account =
    getTransactions authDetails account Nothing Nothing


getTransactions : AuthDetails -> Account -> Maybe Date -> Maybe Date -> Task (Error String) (List Transaction)
getTransactions authDetails account before since =
    let
        beforeParam =
            case before of
                Just date ->
                    [ "before" => (formatDate date) ]

                Nothing ->
                    []

        sinceParam =
            case since of
                Just date ->
                    [ "since" => (formatDate date) ]

                Nothing ->
                    []
    in
        monzoGet "https://api.getmondo.co.uk/transactions"
            authDetails
            decodeTransactionList
            [ "account_id" => account.id
            , "expand[]" => "merchant"
            ]


monzoGet : String -> AuthDetails -> Decoder a -> List ( String, String ) -> Task (Error String) a
monzoGet url authDetails decoder query =
    get (H.url url query)
        |> withHeader "Authorization" ("Bearer " ++ authDetails.accessToken)
        |> send (jsonReader decoder) stringReader
        |> Task.map (\response -> response.data)
