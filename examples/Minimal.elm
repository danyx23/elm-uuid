module MinimalExample 
  ( main
  )
  where

import Uuid
import Random.PCG exposing (Seed, initialSeed2, generate)
import StartApp.Simple exposing (start)
import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)

-- 1.: Plumbing code to get a good initial random seed from Javascript via a port
--     (As described in the docs of mgold/elm-random-pcg) 
-- Elm
port randomSeed : (Int, Int)

seed0 : Seed
seed0 = (uncurry initialSeed2) randomSeed
 
-- 2.: In your elm code, store the seed and update it every time you create a new Uuid
type alias Model = 
  { currentSeed : Seed
  , currentUuid : Maybe Uuid.Uuid
  }

type Action = NewUuid

update : Action -> Model -> Model
update action model =
  case action of 
    NewUuid ->
      let
        (newUuid, newSeed) = generate Uuid.uuidGenerator model.currentSeed
      in
      { model
      | currentUuid = Just newUuid
      , currentSeed = newSeed 
      }

view : Signal.Address Action -> Model -> Html      
view address model =
  let
    uuidText = case model.currentUuid of
                Nothing -> 
                  "No Uuid was created so far"
                Just uuid ->
                    "Current Uuid: " ++ Uuid.toString uuid
  in
    div []
      [ button [ onClick address NewUuid ] [ text "Create a new Uuid!" ]
      , text uuidText          
      ]
    
main =
  start
    { model = { currentSeed = seed0, currentUuid = Nothing }
    , update = update
    , view = view
    }