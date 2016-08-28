module Prelude exposing (..)

import Dict exposing (Dict)
import Task
import String


(=>) =
    (,)


andThen =
    flip Task.andThen


splitAtFirst : Char -> String -> ( String, String )
splitAtFirst c s =
    case (firstOccurrence c s) of
        Nothing ->
            ( s, "" )

        Just i ->
            ( (String.left i s), (String.dropLeft (i + 1) s) )


firstOccurrence : Char -> String -> Maybe Int
firstOccurrence c s =
    case (String.indexes (String.fromChar c) s) of
        [] ->
            Nothing

        head :: _ ->
            Just head


parseSearchString : String -> Maybe (Dict String String)
parseSearchString startsWithQuestionMarkThenParams =
    case (String.uncons startsWithQuestionMarkThenParams) of
        Just ( '?', rest ) ->
            Just (parseParams rest)

        otherwise ->
            Nothing


parseParams : String -> Dict String String
parseParams stringWithAmpersands =
    let
        eachParam =
            (String.split "&" stringWithAmpersands)

        eachPair =
            List.map (splitAtFirst '=') eachParam
    in
        (Dict.fromList eachPair)
