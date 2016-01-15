module Uuid
  ( Uuid
  , toString
  , fromString
  , uuidGenerator
  ) where
  
{-| This modules provides an opaque type for Uuids, helpers to serialize
from and to String and helpers to generate new Uuids using Max Goldsteins
Random.PCG pseudo-random generator library.

Uuids are Universally Unique IDentifiers. They are 128 bit ids that are
designed to be extremely unlikely to collide with other Uuids.

This library only supports generating Version 4 Uuid (those generated using 
random numbers, as opposed to hashing. See 
[Wikipedia on Uuids](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29) 
for more details). Version 4 Uuids are constructed using 122 pseudo random bits.

Disclaimer: If you use this Library to generate Uuids, please be advised
that it does not use a cryptographically secure pseudo random number generator.
While Random.PCG is a definite improvement over Elms native RNG, depending
on your use case the randomness provided may not be enough.  

This library is split into two Modules. Uuid (this module) wraps Uuids in
an opaque type for improved type safety. If you prefer to simply get strings
you can use the Uuid.Barebones module which provides methods to generate
and verify Uuid as plain Strings.

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
    import Random.PCG exposing (generate, Seed, initialSeed2)
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

@docs Uuid, uuidGenerator, fromString, toString
-}

import Random.PCG exposing (Generator, map, list, int, generate, Seed)
import Uuid.Barebones exposing (..)

{-| Uuid type. Represents a 128 bit Uuid (Version 4) 
-}
type Uuid 
  = Uuid String
 
{-| Create a string representation from a Uuid in the canonical 8-4-4-4-12 form, i.e. 
"63B9AAA2-6AAF-473E-B37E-22EB66E66B76"
-}
toString : Uuid -> String
toString (Uuid internalString) =
  internalString

{-| Create a Uuid from a String in the canonical form (e.g. 
"63B9AAA2-6AAF-473E-B37E-22EB66E66B76"). Note that this module only supports 
canonical Uuids, Versions 1-5 and will refuse to parse other Uuid variants.
-}
fromString : String -> Maybe Uuid
fromString text =
  if isValidUuid text then
    Just <| Uuid text
  else
    Nothing

{-| Random.PCG Generator for Uuids. Using this Generator instead of the generate
function let's you use the full power of the Random.PCG to create lists of Uuids, 
map them to other types etc. 
-}
uuidGenerator : Generator Uuid
uuidGenerator =
  map Uuid uuidStringGenerator
  

  
