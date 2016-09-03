module Prelude exposing (..)

import Task
import String


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


andThen : (a -> Task.Task b c) -> Task.Task b a -> Task.Task b c
andThen =
    flip Task.andThen


sendMsg : a -> Cmd a
sendMsg msg =
    Task.succeed True
        |> Task.perform (always msg) (always msg)


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
