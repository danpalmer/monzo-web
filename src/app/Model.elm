module Model exposing (Model, Flags, initialModel)

import Erl
import Routes
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
    { initialPath : String
    , initialSeed : Int
    , startTime : Int
    , baseUrl : String
    , query : String
    }


initialModel : Flags -> Model
initialModel flags =
    let
        baseUrl =
            Erl.parse flags.baseUrl

        params =
            (parseUrlParameters flags.query)
    in
        { currentRoute = Routes.decodePathOr404 flags.initialPath
        , loginModel = Login.init flags.initialSeed baseUrl
        , receiveAuthModel = ReceiveAuth.init params baseUrl flags.startTime
        , accountModel = Account.empty
        , flags = flags
        }
