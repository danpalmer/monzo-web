module Api.Monzo.Util exposing (formatDate)

import Date exposing (Date)
import Date.Format exposing (format)


formatDate : Date -> String
formatDate =
    format "%Y-%m-%dT%H:%M:%SZ"
