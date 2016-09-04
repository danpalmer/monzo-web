module Components.Balance exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Api.Monzo.Models exposing (Account, Balance, Currency(..))


view : Account -> Balance -> Html a
view account balance =
    div [ class "component-balance" ]
        [ div [ class "balance-unit" ]
            [ viewAmount balance.balance balance.currency
            , div [ class "description" ] [ text "Card Balance" ]
            ]
        , div [ class "balance-unit" ]
            [ viewAmount balance.spendToday balance.currency
            , div [ class "description" ] [ text "Spend Today" ]
            ]
        ]


viewAmount : Int -> Currency -> Html a
viewAmount amount currency =
    div [ class "balance" ]
        [ span [ class "currency" ] [ text (formatCurrency currency) ]
        , span [ class "amount" ] [ text (formatAmount amount) ]
        ]


formatAmount : Int -> String
formatAmount x =
    let
        major =
            x // 100

        minor =
            x `rem` 100

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
