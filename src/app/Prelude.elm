module Prelude exposing (..)

import Task
import String


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


sendMsg : a -> Cmd a
sendMsg msg =
    Task.succeed True
        |> Task.perform (always msg)


join3 : List a -> List a -> List a -> List a
join3 xs ys zs =
    List.append ys zs |> List.append xs


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


resultToMsg : c -> c -> Result a b -> c
resultToMsg err succ r =
    case r of
        Err _ ->
            err

        Ok _ ->
            succ


resultDetailToMsg : (a -> c) -> (b -> c) -> Result a b -> c
resultDetailToMsg err succ r =
    case r of
        Err e ->
            err e

        Ok s ->
            succ s
