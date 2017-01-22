module Utils.Auth exposing (..)

import Json.Decode as JD
import Json.Encode as JE
import Task exposing (Task)
import Result
import LocalStorage
import Settings
import Api.Monzo.Models exposing (ApiAuthDetails)


type alias AuthDetails =
    { accessToken : String
    , expiresAt : Int
    , userID : String
    }


emptyAuthDetails : AuthDetails
emptyAuthDetails =
    AuthDetails "" 0 ""


isEmpty : AuthDetails -> Bool
isEmpty authDetails =
    authDetails.expiresAt == 0


authDetailsDecoder : JD.Decoder AuthDetails
authDetailsDecoder =
    JD.map3
        AuthDetails
        (JD.field "access_token" JD.string)
        (JD.field "expires_at" JD.int)
        (JD.field "user_id" JD.string)


decodeAuthDetails : String -> Result String AuthDetails
decodeAuthDetails str =
    JD.decodeString authDetailsDecoder str


decodeAuthDetailsTask : String -> Task String AuthDetails
decodeAuthDetailsTask str =
    case (decodeAuthDetails str) of
        Err e ->
            Task.fail e

        Ok s ->
            Task.succeed s


encodeAuthDetails : AuthDetails -> String
encodeAuthDetails authDetails =
    JE.encode 0
        (JE.object
            [ ( "access_token", JE.string authDetails.accessToken )
            , ( "expires_at", JE.int authDetails.expiresAt )
            , ( "user_id", JE.string authDetails.userID )
            ]
        )


apiAuthDetailsToAuthDetails : ApiAuthDetails -> Int -> AuthDetails
apiAuthDetailsToAuthDetails apiAuthDetails appStartTime =
    AuthDetails
        apiAuthDetails.accessToken
        ((apiAuthDetails.expiresIn * 1000) + appStartTime)
        apiAuthDetails.userID



-- Commands


setAuthDetailsInStorage : AuthDetails -> Task LocalStorage.Error ()
setAuthDetailsInStorage authDetails =
    LocalStorage.set Settings.authDetailsKey (encodeAuthDetails authDetails)


getAuthDetailsFromStorage : Int -> Task String AuthDetails
getAuthDetailsFromStorage appStartTime =
    LocalStorage.get Settings.authDetailsKey
        |> Task.mapError localStorageErrorToString
        |> Task.andThen decodeAuthDetailsTask



-- Utils


expired : AuthDetails -> Int -> Bool
expired authDetails appStartTime =
    authDetails.expiresAt < appStartTime


localStorageErrorToString : LocalStorage.Error -> String
localStorageErrorToString e =
    case e of
        LocalStorage.KeyNotFound s ->
            s
