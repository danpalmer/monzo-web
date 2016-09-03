module Api.Monzo.Models exposing (..)


type alias ApiAuthDetails =
    { accessToken : String
    , expiresIn : Int
    , userID : String
    }
