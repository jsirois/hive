module Main exposing (..)

import Html exposing (Html, text)
import Window exposing (resizes, Size)


type alias Model =
    Size


init : ( Model, Cmd WindowResize )
init =
    ( { width = 0, height = 0 }, Cmd.none )


view : Model -> Html WindowResize
view model =
    text ("Window is " ++ toString model.width ++ "x" ++ toString model.height)


type alias WindowResize =
    Size


update : WindowResize -> Model -> ( Model, Cmd WindowResize )
update resize size =
    ( resize, Cmd.none )


handleResize : Size -> WindowResize
handleResize size =
    size


subscriptions : Model -> Sub WindowResize
subscriptions model =
    Window.resizes handleResize


main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }
