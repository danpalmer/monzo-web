module Api.Monzo.Decoder exposing (..)

import Api.Monzo.Models exposing (..)
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))


decodeApiAuthDetails : JD.Decoder ApiAuthDetails
decodeApiAuthDetails =
    JD.object3
        ApiAuthDetails
        ("access_token" := JD.string)
        ("expires_in" := JD.int)
        ("user_id" := JD.string)
