module Components.TransactionsList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Api.Monzo.Models exposing (Account, Transaction, Currency(..))
import Components.Transaction as TransactionComponent


view : Account -> List Transaction -> Html a
view account transactions =
    div [ class "component-transactions-list" ]
        (List.map TransactionComponent.view transactions)
