module Api.Monzo.Decoder exposing (..)

import Erl exposing (Url)
import Api.Monzo.Models exposing (..)
import Json.Decode exposing (..)
import Json.Decode as JD
import Json.Decode.Extra exposing (..)


decodeApiAuthDetails : Decoder ApiAuthDetails
decodeApiAuthDetails =
    map3
        ApiAuthDetails
        (field "access_token" string)
        (field "expires_in" int)
        (field "user_id" string)


decodeAccount : Decoder Account
decodeAccount =
    map3
        Account
        (field "id" string)
        (field "description" string)
        (field "created" date)


decodeCurrency : Decoder Currency
decodeCurrency =
    andThen
        (\currencyValue ->
            case currencyValue of
                "GBP" ->
                    succeed GBP

                "USD" ->
                    succeed USD

                "EUR" ->
                    succeed EUR

                otherwise ->
                    fail "Unsupported currency"
        )
        string


decodeBalance : Decoder Balance
decodeBalance =
    map3
        Balance
        (field "balance" int)
        (field "currency" decodeCurrency)
        (field "spend_today" int)


decodeAddress : Decoder Address
decodeAddress =
    map7
        Address
        (field "address" string)
        (field "city" string)
        (field "country" string)
        (field "latitude" float)
        (field "longitude" float)
        (field "postcode" string)
        (field "region" string)


decodeTransactionCategory : Decoder TransactionCategory
decodeTransactionCategory =
    andThen
        (\categoryValue ->
            case categoryValue of
                "general" ->
                    succeed General

                "eating_out" ->
                    succeed EatingOut

                "expenses" ->
                    succeed Expenses

                "transport" ->
                    succeed Transport

                "cash" ->
                    succeed Cash

                "bills" ->
                    succeed Bills

                "entertainment" ->
                    succeed Entertainment

                "shopping" ->
                    succeed Shopping

                "holidays" ->
                    succeed Holidays

                "groceries" ->
                    succeed Groceries

                otherwise ->
                    fail "Unsupported transaction category"
        )
        string


decodeUrl : Decoder Url
decodeUrl =
    andThen
        (\urlString ->
            succeed (Erl.parse urlString)
        )
        string


decodeMerchant : Decoder Merchant
decodeMerchant =
    map8
        Merchant
        (field "address" decodeAddress)
        (field "created" date)
        (field "group_id" string)
        (field "id" string)
        (field "logo" decodeUrl)
        (field "emoji" string)
        (field "name" string)
        (field "category" decodeTransactionCategory)


decodeDeclineReason : Decoder DeclineReason
decodeDeclineReason =
    andThen
        (\declineReason ->
            case declineReason of
                "INSUFFICIENT_FUNDS" ->
                    succeed InsufficientFunds

                "CARD_INACTIVE" ->
                    succeed CardInactive

                "CARD_BLOCKED" ->
                    succeed CardBlocked

                "OTHER" ->
                    succeed OtherReason

                otherwise ->
                    fail "Unsupported decline reason"
        )
        string


decodeTransaction : Decoder Transaction
decodeTransaction =
    succeed Transaction
        |: (field "account_balance" int)
        |: (field "amount" int)
        |: (field "created" date)
        |: (field "currency" decodeCurrency)
        |: (field "description" string)
        |: (field "id" string)
        |: (field "merchant" (nullable decodeMerchant)
                |> (withDefault Nothing)
           )
        |: (field "notes" string)
        |: (field "is_load" bool)
        |: (field "settled" (nullable date)
                |> (withDefault Nothing)
           )
        |: (field "decline_reason" (nullable decodeDeclineReason)
                |> (withDefault Nothing)
           )


decodeAccountList : Decoder (List Account)
decodeAccountList =
    (field "accounts" (list decodeAccount))


decodeTransactionList : Decoder (List Transaction)
decodeTransactionList =
    (field "transactions" (list decodeTransaction))
