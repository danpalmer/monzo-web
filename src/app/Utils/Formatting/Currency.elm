module Utils.Formatting.Currency exposing (..)

import Api.Monzo.Models exposing (Currency(..))


formatAmount : Int -> String
formatAmount x =
    let
        major =
            x // 100

        minor =
            rem x 100

        zeros =
            if minor < 10 then
                "0"
            else
                ""
    in
        (toString major) ++ "." ++ zeros ++ (toString minor)


formatCurrency : Currency -> String
formatCurrency c =
    case c of
        GBP ->
            "£"

        USD ->
            "$"

        EUR ->
            "€"
