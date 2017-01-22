module Components.Transaction exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, src)
import Erl
import Utils.Formatting.Currency exposing (formatAmount)
import Api.Monzo.Models exposing (Transaction, Merchant, Currency(..))


view : Transaction -> Html a
view transaction =
    case ( transaction.merchant, transaction.isLoad ) of
        ( Just merchant, _ ) ->
            div [ class "component-transaction merchant" ]
                (viewMerchantTransaction transaction merchant)

        ( _, True ) ->
            div [ class "component-transaction top-up" ]
                (viewTopUp transaction)

        otherwise ->
            div [ class "component-transaction" ]
                [ text "unsupported transaction type" ]


viewMerchantTransaction : Transaction -> Merchant -> List (Html a)
viewMerchantTransaction transaction merchant =
    let
        logoUrl =
            Erl.toString merchant.logo

        amount =
            formatAmount transaction.amount
    in
        [ img [ class "icon", src logoUrl ] []
        , div [ class "name" ] [ text merchant.name ]
        , div [ class "amount" ] [ text amount ]
        ]


viewTopUp : Transaction -> List (Html a)
viewTopUp transaction =
    let
        amount =
            "+ "
                ++ (formatAmount transaction.amount)
    in
        [ img [ class "icon", src "http://placehold.it/30/30" ] []
        , div [ class "name" ] [ text "Top Up" ]
        , div [ class "amount" ] [ text amount ]
        ]
