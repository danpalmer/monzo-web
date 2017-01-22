module Components.AccountSummary exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Utils.Formatting.Currency exposing (..)
import Api.Monzo.Models exposing (Account, Balance, Currency(..))


view : Account -> Balance -> Html a
view account balance =
    div [ class "component-account-summary" ]
        [ div [ class "balance-unit" ]
            [ viewAmount balance.balance balance.currency
            , div [ class "description" ] [ text "Card Balance" ]
            ]
        , div [ class "balance-unit" ]
            [ viewAmount (abs balance.spendToday) balance.currency
            , div [ class "description" ] [ text "Spend Today" ]
            ]
        ]


viewAmount : Int -> Currency -> Html a
viewAmount amount currency =
    div [ class "balance" ]
        [ span [ class "currency" ] [ text (formatCurrency currency) ]
        , span [ class "amount" ] [ text (formatAmount amount) ]
        ]
