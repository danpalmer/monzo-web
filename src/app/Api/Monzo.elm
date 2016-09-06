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
            Settings.monzoAuthBase
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


exchangeAuthCode : String -> Erl.Url -> Task ApiError ApiAuthDetails
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
        post (monzoUrl [ "oauth2", "token" ])
            |> withUrlEncodedBody data
            |> withHeader "Content-type" "application/x-www-form-urlencoded"
            |> send (jsonReader decodeApiAuthDetails) stringReader
            |> Task.map (\response -> response.data)
            |> Task.mapError httpErrorToApiError


getAccounts : AuthDetails -> Task ApiError (List Account)
getAccounts authDetails =
    monzoGet [ "accounts" ] authDetails decodeAccountList []


getBalance : AuthDetails -> Account -> Task ApiError Balance
getBalance authDetails account =
    monzoGet [ "balance" ]
        authDetails
        decodeBalance
        [ "account_id" => account.id
        ]


getRecentTransactions : AuthDetails -> Account -> Task ApiError (List Transaction)
getRecentTransactions authDetails account =
    getTransactions authDetails account Nothing Nothing


getTransactions : AuthDetails -> Account -> Maybe Date -> Maybe Date -> Task ApiError (List Transaction)
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
        monzoGet [ "transactions" ]
            authDetails
            decodeTransactionList
            [ "account_id" => account.id
            , "expand[]" => "merchant"
            ]



-- Utils


type ApiError
    = NetworkError
    | ClientError
    | ServerError


httpErrorToApiError : Error String -> ApiError
httpErrorToApiError err =
    case err of
        H.UnexpectedPayload _ ->
            ServerError

        H.NetworkError ->
            NetworkError

        H.Timeout ->
            NetworkError

        H.BadResponse _ ->
            ClientError


monzoGet : List String -> AuthDetails -> Decoder a -> List ( String, String ) -> Task ApiError a
monzoGet urlSegments authDetails decoder query =
    get (H.url (monzoUrl urlSegments) query)
        |> withHeader "Authorization" ("Bearer " ++ authDetails.accessToken)
        |> send (jsonReader decoder) stringReader
        |> Task.map (\response -> response.data)
        |> Task.mapError httpErrorToApiError


monzoUrl : List String -> String
monzoUrl segments =
    Erl.toString (Erl.appendPathSegments segments Settings.monzoApiBase)
