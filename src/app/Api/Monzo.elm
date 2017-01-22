module Api.Monzo exposing (..)

import Date exposing (Date)
import Task exposing (..)
import Json.Decode exposing (Decoder)
import Erl
import Http
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
            |> withExpect (Http.expectJson decodeApiAuthDetails)
            |> toTask
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
    getTransactions authDetails account Nothing Nothing (Just 100)


getTransactions : AuthDetails -> Account -> Maybe Date -> Maybe Date -> Maybe Int -> Task ApiError (List Transaction)
getTransactions authDetails account before since limit =
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

        limitParam =
            case limit of
                Just lim ->
                    [ "limit" => (toString lim) ]

                Nothing ->
                    []

        query =
            [ "account_id" => account.id
            , "expand[]" => "merchant"
            ]
                ++ beforeParam
                ++ sinceParam
                ++ limitParam
    in
        monzoGet [ "transactions" ]
            authDetails
            decodeTransactionList
            query



-- Utils


type ApiError
    = NetworkError
    | ClientError String
    | ServerError String


describeApiError : ApiError -> ( String, String )
describeApiError err =
    case err of
        NetworkError ->
            ( "Couldn't connect to Monzo", "Are you connected to the internet?" )

        ServerError e ->
            ( "Something went wrong", e )

        ClientError e ->
            ( "Something went wrong", e )


httpErrorToApiError : Http.Error -> ApiError
httpErrorToApiError err =
    case err of
        Http.BadPayload e _ ->
            ServerError e

        Http.NetworkError ->
            NetworkError

        Http.Timeout ->
            NetworkError

        Http.BadStatus resp ->
            if (statusIsServerError resp) then
                ServerError resp.status.message
            else
                ClientError resp.status.message

        Http.BadUrl url ->
            ClientError ("Invalid URL: " ++ url)


statusIsServerError : Http.Response a -> Bool
statusIsServerError resp =
    resp.status.code >= 500 && resp.status.code < 600


monzoGet : List String -> AuthDetails -> Decoder a -> List ( String, String ) -> Task ApiError a
monzoGet urlSegments authDetails decoder query =
    get (monzoUrl urlSegments)
        |> withQueryParams query
        |> withHeader "Authorization" ("Bearer " ++ authDetails.accessToken)
        |> withExpect (Http.expectJson decoder)
        |> toTask
        |> Task.mapError httpErrorToApiError


monzoUrl : List String -> String
monzoUrl segments =
    Erl.toString (Erl.appendPathSegments segments Settings.monzoApiBase)
