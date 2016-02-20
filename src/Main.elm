import StartApp.Simple exposing (start)

import CounterList exposing (update, view, init)

main =
    start { model = init, view = view, update = update }
