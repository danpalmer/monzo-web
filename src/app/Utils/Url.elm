module Utils.Url exposing (parseUrlParameters)

import String
import Dict exposing (Dict)
import Prelude exposing (splitAtFirst)


-- Parse &-separated key=value pairs out of a string


parseParams : String -> Dict String String
parseParams stringWithAmpersands =
    let
        eachParam =
            (String.split "&" stringWithAmpersands)

        eachPair =
            List.map (splitAtFirst '=') eachParam
    in
        (Dict.fromList eachPair)



-- Parse the query out of a string, if there is one


parseSearchString : String -> Maybe (Dict String String)
parseSearchString startsWithQuestionMarkThenParams =
    case (String.uncons startsWithQuestionMarkThenParams) of
        Just ( '?', rest ) ->
            Just (parseParams rest)

        otherwise ->
            Nothing



-- Parse the URL parameters from a string


parseUrlParameters : String -> Dict String String
parseUrlParameters query =
    let
        maybeParams =
            parseSearchString query
    in
        Maybe.withDefault Dict.empty maybeParams
