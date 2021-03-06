module View exposing (..)

import Html exposing (..)
import Routes
import Model exposing (Model)
import Update exposing (Msg(..))
import Views.Login as Login
import Views.ReceiveAuth as ReceiveAuth
import Views.Account as Account
import Views.Loading as Loading
import Views.NotFound as NotFound


contentView : Model -> Html Msg
contentView model =
    case model.currentRoute of
        Routes.Home ->
            Loading.view

        Routes.Login ->
            Html.map LoginMsg (Login.view model.loginModel)

        Routes.ReceiveAuth ->
            Html.map ReceiveAuthMsg (ReceiveAuth.view model.receiveAuthModel)

        Routes.Account ->
            Html.map AccountMsg (Account.view model.accountModel)

        Routes.NotFound ->
            NotFound.view


view : Model -> Html Msg
view model =
    contentView model
