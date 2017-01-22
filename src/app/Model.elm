module Model exposing (Model, Flags, initialModel)

import Erl
import Routes
import Navigation exposing (Location)
import Utils.Url exposing (parseUrlParameters)
import Views.Login as Login
import Views.ReceiveAuth as ReceiveAuth
import Views.Account as Account


type alias Model =
    { currentRoute : Routes.Route
    , loginModel : Login.Model
    , receiveAuthModel : ReceiveAuth.Model
    , accountModel : Account.Model
    , flags : Flags
    }


type alias Flags =
    { initialSeed : Int
    , startTime : Int
    , baseUrl : String
    , query : String
    }


initialModel : Flags -> Location -> Model
initialModel flags location =
    let
        baseUrl =
            Erl.parse flags.baseUrl

        params =
            (parseUrlParameters flags.query)
    in
        { currentRoute = Routes.decodeOr404 location
        , loginModel = Login.init flags.initialSeed baseUrl
        , receiveAuthModel = ReceiveAuth.init params baseUrl flags.startTime
        , accountModel = Account.empty
        , flags = flags
        }
