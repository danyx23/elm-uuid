module Uuid
  ( Uuid
  , toString
  , fromString
  , generate
  ) where
  
{-| This modules provides an opaque type for Uuids, helpers to serialize
from and to String and helpers to generate new Uuids using Max Goldsteins
Random.PCG pseudo-random generator library.

Uuids are Universally Unique IDentifiers. They are 128 bit ids that are
designed to be extremely unlikely to collide with other Uuids.

This library only supports Version 4 Uuid (those generated using random numbers,
as opposed to hashing. See [Wikipedia on Uuids](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29) 
for more details). Version 4 Uuids are constructed using 122 pseudo random bits.

Uuids can be generated either by parsing them from the canonical string representation
(see fromString) or by generating them. If you are unfamiliar with random number generation
in pure functional languages, this can be a bit confusing. The gist of it is that:

1. you need a good random seed and this has to come from outside our wonderfully
predictable Elm code (meaning you have to create an incoming port and feed in
some initial randomness)

2. every call to generate a new Uuid will give you a tuple of a Uuid and a new 
seed. It is very important that whenever you generate a new Uuid you store this
seed you get back into your model and use this one for the next Uuid generation. 
If you reuse a seed, you will create the same Uuid twice! 

Here is a complete example that shows how to initialize the random number seed
and how to carry the returned seed forward to the next Uuid generation.

    import Uuid
    import Random.PCG exposing (Seed, initialSeed2)
    import StartApp.Simple exposing (start)
    import Html exposing (Html, div, button, text)
    import Html.Events exposing (onClick)

    -- 1.: Plumbing code to get a good initial random seed from Javascript 
    --     via a port (As described in the docs of mgold/elm-random-pcg) 
    port randomSeed : (Int, Int)

    seed0 : Seed
    seed0 = (uncurry initialSeed2) randomSeed

    -- attention, this has to go in your Javascript code
    -- Begin JS code
    Elm.fullscreen(Elm.ModuleName,
      {randomSeed: [Math.floor(Math.random()*0xFFFFFFFF), 
                    Math.floor(Math.random()*0xFFFFFFFF)] })
    -- End JS code
      
    -- 2.: In your elm code, store the seed and update it every time you 
    --     create a new Uuid
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
            (newUuid, newSeed) = Uuid.generate model.currentSeed
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

@docs Uuid, generate, fromString, toString
-}

import String
import List
import Array
import Char
import Regex
import Bitwise
import Random.PCG exposing (Generator, map, list, int, generate, Seed)

{-| Uuid type. Represents a 128 bit Uuid (Version 4) 
-}
type Uuid 
  = Uuid String

{-| Generate a new pair of Uuid and Seed. Don't forget to store the returned
Seed and provide that one the next time you call generate! 
-}
generate : Seed -> (Uuid, Seed)
generate seed =
  Random.PCG.generate uuidGenerator seed
  
{-| Create a string representation from a Uuid in the canonical 8-4-4-4-12 form, i.e. 
"63B9AAA2-6AAF-473E-B37E-22EB66E66B76"
-}
toString : Uuid -> String
toString (Uuid internalString) =
  internalString

{-| Create a Uuid from a String in the canonical form (e.g. 
"63B9AAA2-6AAF-473E-B37E-22EB66E66B76"). Note that this module only supports 
Version 4 Uuids and will refuse to parse other Uuid versions (i.e. only Uuids 
in the form xxxxxxxx-xxxx-4xxx-Yxxx-xxxxxxxxxxxx will be successfully parsed)
-}
fromString : String -> Maybe Uuid
fromString text =
  if Regex.contains uuidRegex text then
    Just <| Uuid text
  else
    Nothing

type UuidGenerator 
  = UuidGenerator (Generator Uuid)

mapToHex index =
  let
    maybeResult = (flip Array.get <| hexDigits) index
  in
    case maybeResult of
      Nothing ->
        'x'
      Just result ->
        result

hexGenerator =
  int 0 15   

uuidGenerator : Generator Uuid
uuidGenerator =
  map createUuid (list 31 hexGenerator)

limitDigitRange8ToB digit =
  digit `Bitwise.and` 3 `Bitwise.or` 8 

createUuid thirtyOneHexDigits =
  String.concat
  [ thirtyOneHexDigits |> List.take 8 |> (List.map mapToHex) |> String.fromList
  , "-"
  , thirtyOneHexDigits |> List.drop 8 |> List.take 4|> (List.map mapToHex) |> String.fromList
  , "-"
  , "4"
  , thirtyOneHexDigits |> List.drop 12 |> List.take 3|> (List.map mapToHex) |> String.fromList
  , "-"
  , thirtyOneHexDigits |> List.drop 15 |> List.take 1|> (List.map limitDigitRange8ToB) |> (List.map mapToHex) |> String.fromList
  , thirtyOneHexDigits |> List.drop 16 |> List.take 3|> (List.map mapToHex) |> String.fromList
  , "-"
  , thirtyOneHexDigits |> List.drop 19 |> List.take 12|> (List.map mapToHex) |> String.fromList
  ]
  |> Uuid
  
uuidRegex =
  Regex.regex "^[0-9A-Fa-f]{8,8}-[0-9A-Fa-f]{4,4}-4[0-9A-Fa-f]{3,3}-[8-9A-Ba-b][0-9A-Fa-f]{3,3}-[0-9A-Fa-f]{12,12}$"
  
hexDigits = 
  let
    mapChars offset digit = Char.fromCode <| digit + offset
  in
    (List.map (mapChars 48) [0..9]) ++ (List.map (mapChars 65) [0..5])
    |> Array.fromList