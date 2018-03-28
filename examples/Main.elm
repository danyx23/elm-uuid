module Main exposing (main)

import Uuid
import Random.Pcg.Extended exposing (Seed, initialSeed, step)
import Html exposing (Html, div, button, text, programWithFlags)
import Html.Events exposing (onClick)


-- 1.: In your elm code, store the seed and update it every time you create a new Uuid


type alias Model =
    { currentSeed : Seed
    , currentUuid : Maybe Uuid.Uuid
    }


type Msg
    = NewUuid


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUuid ->
            let
                ( newUuid, newSeed ) =
                    step Uuid.generator model.currentSeed
            in
                ( { model
                    | currentUuid = Just newUuid
                    , currentSeed = newSeed
                  }
                , Cmd.none
                )


view : Model -> Html Msg
view model =
    let
        uuidText =
            case model.currentUuid of
                Nothing ->
                    "No Uuid was created so far"

                Just uuid ->
                    "Current Uuid: " ++ Uuid.toString uuid
    in
        div []
            [ button [ onClick NewUuid ] [ text "Create a new Uuid!" ]
            , text uuidText
            ]


{-| To get enough bytes of randomness (128 bit), we have to pass at least 4 32-bit ints from JavaScript
via flags. Here we pass 5, since having a seedExtension of a size that is a power of 2 results
in slightly faster performance.
-}
init : ( Int, List Int ) -> ( Model, Cmd Msg )
init ( seed, seedExtension ) =
    ( { currentSeed = initialSeed seed seedExtension
      , currentUuid = Nothing
      }
    , Cmd.none
    )


main : Program ( Int, List Int ) Model Msg
main =
    programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
