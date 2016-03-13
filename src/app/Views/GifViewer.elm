module Views.GifViewer (Model, init, Action, update, view, onLoadEffect) where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task


-- Model


type alias Model =
  { topic : String
  , gifUrl : Maybe String
  }


init : String -> Model
init topic =
  Model topic Nothing



-- Update


type Action
  = RequestMore
  | NewGif (Maybe String)


update : Action -> Model -> ( Model, Effects Action )
update msg model =
  case msg of
    RequestMore ->
      ( model
      , getRandomGif model.topic
      )

    NewGif maybeUrl ->
      ( Model model.topic maybeUrl
      , Effects.none
      )



-- View


(=>) =
  (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div
    [ style [ "width" => "200px" ] ]
    [ h2 [ headerStyle ] [ text model.topic ]
    , div (imgStyle model.gifUrl) []
    , button [ onClick address RequestMore ] [ text "Load more..." ]
    ]


headerStyle : Attribute
headerStyle =
  style
    [ "width" => "200px"
    , "text-align" => "center"
    ]


imgStyle : Maybe String -> List Attribute
imgStyle maybeUrl =
  case maybeUrl of
    Nothing ->
      [ class "gif" ]

    Just url ->
      [ style [ "background-image" => ("url('" ++ url ++ "')") ]
      , class "gif"
      ]



-- Effects


onLoadEffect : Model -> Effects Action
onLoadEffect model =
  getRandomGif model.topic


getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task


randomUrl : String -> String
randomUrl topic =
  Http.url
    "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


decodeImageUrl : Json.Decoder String
decodeImageUrl =
  Json.at [ "data", "image_url" ] Json.string
