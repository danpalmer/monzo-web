module Views.Login (Model, init, Action, update, view, mountedRoute) where

import Random exposing (initialSeed, Seed)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, class, href)
import Http
import Json.Decode as Json
import Task
import Routes
import Api.Mondo as Mondo
import Signal
import Erl
import Prelude exposing (..)


-- Model


type alias Model =
  { randomStateSeed : Seed
  , redirectUrl : Erl.Url
  , redirectMailbox : Signal.Mailbox String
  }


init : Int -> Signal.Mailbox String -> Model
init seed mailbox =
  { randomStateSeed = initialSeed seed
  , redirectUrl = Erl.new
  , redirectMailbox = mailbox
  }


mountedRoute : Model -> ( Model, Effects Action )
mountedRoute model =
  let
    ( url, seed' ) =
      Mondo.loginUrl model.randomStateSeed
  in
    ( { model | randomStateSeed = seed', redirectUrl = url }
    , Effects.none
    )



-- Update


type Action
  = Redirected
    -- Never reached
  | ReceiveLogin


update : Action -> Model -> ( Model, Effects Action )
update msg model =
  case msg of
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


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ "width" => "200px" ] ]
    [ a [ href (Erl.toString model.redirectUrl) ] [ text "Login" ]
    ]
