module MinimalExample
    exposing
        ( main
        )

import Uuid
import Random.Pcg exposing (Seed, initialSeed, step)
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
                    step Uuid.uuidGenerator model.currentSeed
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



{- this init function takes an int that is handed over
   in the initializiation code of our Elm app in the javascript code. It
   uses this JS random value as the initial seed.
-}


init : Int -> ( Model, Cmd Msg )
init seed =
    ( { currentSeed = initialSeed seed
      , currentUuid = Nothing
      }
    , Cmd.none
    )


main : Program Int Model Msg
main =
    programWithFlags
        -- using programWithFlags to get the seed values from JS
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
