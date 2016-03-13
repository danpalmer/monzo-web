module Views.Login (Model, init, Action, update, view) where

import Random exposing (initialSeed, Seed)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task
import Routes
import Api.Mondo as Mondo
import Signal


-- Model


type alias Model =
  { randomStateSeed : Seed
  , redirectMailbox : Signal.Mailbox String
  }


init : Int -> Signal.Mailbox String -> Model
init seed mailbox =
  { randomStateSeed = initialSeed seed
  , redirectMailbox = mailbox
  }



-- Update


type Action
  = PrepareLogin
  | Redirected
    -- Never reached
  | ReceiveLogin


update : Action -> Model -> ( Model, Effects Action )
update msg model =
  case msg of
    PrepareLogin ->
      let
        ( url, seed' ) =
          Mondo.loginUrl model.randomStateSeed
      in
        ( { model | randomStateSeed = seed' }
        , redirectToUrl model.redirectMailbox url
        )

    otherwise ->
      ( model
      , Effects.none
      )


redirectToUrl mailbox url =
  Signal.send mailbox.address url
    |> Task.map (\_ -> Redirected)
    |> flip Task.onError (\_ -> Task.succeed Redirected)
    |> Effects.task



-- View


(=>) =
  (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ "width" => "200px" ] ]
    [ button [ onClick address PrepareLogin ] [ text "Login" ]
    ]
