module Api.Monzo.Models exposing (..)

import Date exposing (Date)
import Erl exposing (Url)


type alias ApiAuthDetails =
    { accessToken : String
    , expiresIn : Int
    , userID : String
    }


type alias Account =
    { id : String
    , description : String
    , created : Date
    }


type Currency
    = GBP
    | USD
    | EUR


type alias Balance =
    { balance : Int
    , currency : Currency
    , spendToday : Int
    }


type alias Address =
    { address : String
    , city : String
    , country : String
    , latitude : Float
    , longitude : Float
    , postcode : String
    , region : String
    }


type TransactionCategory
    = General
    | EatingOut
    | Expenses
    | Transport
    | Cash
    | Bills
    | Entertainment
    | Shopping
    | Holidays
    | Groceries


type alias MerchantGroup =
    String


type alias Merchant =
    { address : Address
    , created : Date
    , group : MerchantGroup
    , id : String
    , logo : Url
    , emoji : String
    , name : String
    , category : TransactionCategory
    }


type DeclineReason
    = InsufficientFunds
    | CardInactive
    | CardBlocked
    | OtherReason


type alias Transaction =
    { accountBalance : Int
    , amount : Int
    , created : Date
    , currency : Currency
    , description : String
    , id : String
    , merchant : Merchant
    , notes : String
    , isLoad : Bool
    , settled : Maybe Date
    , declineReason : Maybe DeclineReason
    }
