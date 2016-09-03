module Api.Monzo.Decoder exposing (..)

import Result
import Erl exposing (Url)
import Api.Monzo.Models exposing (..)
import Json.Decode exposing (..)
import Json.Decode.Extra exposing (..)


decodeApiAuthDetails : Decoder ApiAuthDetails
decodeApiAuthDetails =
    object3
        ApiAuthDetails
        ("access_token" := string)
        ("expires_in" := int)
        ("user_id" := string)


decodeAccount : Decoder Account
decodeAccount =
    object3
        Account
        ("id" := string)
        ("description" := string)
        ("created" := date)


decodeCurrency : Decoder Currency
decodeCurrency =
    customDecoder string
        (\currencyValue ->
            case currencyValue of
                "GBP" ->
                    Result.Ok GBP

                "USD" ->
                    Result.Ok USD

                "EUR" ->
                    Result.Ok EUR

                otherwise ->
                    Result.Err "Unsupported currency"
        )


decodeBalance : Decoder Balance
decodeBalance =
    object3
        Balance
        ("balance" := int)
        ("currency" := decodeCurrency)
        ("spend_today" := int)


decodeAddress : Decoder Address
decodeAddress =
    object7
        Address
        ("address" := string)
        ("city" := string)
        ("country" := string)
        ("latitude" := float)
        ("longitude" := float)
        ("postcode" := string)
        ("region" := string)


decodeTransactionCategory : Decoder TransactionCategory
decodeTransactionCategory =
    customDecoder string
        (\categoryValue ->
            case categoryValue of
                "general" ->
                    Result.Ok General

                "eating_out" ->
                    Result.Ok EatingOut

                "expenses" ->
                    Result.Ok Expenses

                "transport" ->
                    Result.Ok Transport

                "cash" ->
                    Result.Ok Cash

                "bills" ->
                    Result.Ok Bills

                "entertainment" ->
                    Result.Ok Entertainment

                "shopping" ->
                    Result.Ok Shopping

                "holidays" ->
                    Result.Ok Holidays

                "groceries" ->
                    Result.Ok Groceries

                otherwise ->
                    Result.Err "Unsupported transaction category"
        )


decodeUrl : Decoder Url
decodeUrl =
    customDecoder string
        (\urlString ->
            Result.Ok (Erl.parse urlString)
        )


decodeMerchant : Decoder Merchant
decodeMerchant =
    object8
        Merchant
        ("address" := decodeAddress)
        ("created" := date)
        ("group" := string)
        ("id" := string)
        ("logo" := decodeUrl)
        ("emoji" := string)
        ("name" := string)
        ("category" := decodeTransactionCategory)


decodeDeclineReason : Decoder DeclineReason
decodeDeclineReason =
    customDecoder string
        (\declineReason ->
            case declineReason of
                "INSUFFICIENT_FUNDS" ->
                    Result.Ok InsufficientFunds

                "CARD_INACTIVE" ->
                    Result.Ok CardInactive

                "CARD_BLOCKED" ->
                    Result.Ok CardBlocked

                "OTHER" ->
                    Result.Ok OtherReason

                otherwise ->
                    Result.Err "Unsupported decline reason"
        )


decodeTransaction : Decoder Transaction
decodeTransaction =
    succeed Transaction
        |: ("account_balance" := int)
        |: ("amount" := int)
        |: ("created" := date)
        |: ("currency" := decodeCurrency)
        |: ("description" := string)
        |: ("id" := string)
        |: ("merchant" := decodeMerchant)
        |: ("notes" := string)
        |: ("is_load" := bool)
        |: ("settled" := date)
        |: ("decline_reason" := maybe decodeDeclineReason)


decodeAccountList : Decoder (List Account)
decodeAccountList =
    ("accounts" := (list decodeAccount))


decodeTransactionList : Decoder (List Transaction)
decodeTransactionList =
    ("transactions" := (list decodeTransaction))
