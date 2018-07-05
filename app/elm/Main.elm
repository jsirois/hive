module Main exposing (..)

import Html exposing (Html, text)
import Task exposing (Task)
import Window exposing (resizes, size, Size)


type alias Model =
    { windowSize : Maybe Size
    }


type Msg
    = Nop
    | WindowSize Size


processSize : Result x Size -> Msg
processSize result =
    case result of
        Ok size ->
            WindowSize size

        Err _ ->
            Nop


init : ( Model, Cmd Msg )
init =
    ( { windowSize = Nothing }, Task.attempt processSize Window.size )


view : Model -> Html Msg
view model =
    case model.windowSize of
        Just size ->
            text ("Window is " ++ toString size.width ++ "x" ++ toString size.height)

        Nothing ->
            text "Unknown window size!"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowSize size ->
            ( { windowSize = Just size }, Cmd.none )

        Nop ->
            ( model, Cmd.none )







subscriptions : Model -> Sub Msg
subscriptions model =
    Window.resizes WindowSize


main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }
