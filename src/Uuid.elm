module Uuid exposing (Uuid, toString, fromString, generator, stringGenerator, encode, decoder, isValidUuid)

{-| This modules provides an opaque type for Uuids, helpers to serialize
from and to String and helpers to generate new Uuids using the
[Random.Pcg.Extended](http://package.elm-lang.org/packages/Zinggi/elm-random-pcg-extended/latest)
pseudo-random generator library.

Uuids are Universally Unique IDentifiers. They are 128 bit ids that are
designed to be extremely unlikely to collide with other Uuids.

This library only supports generating Version 4 Uuid (those generated using
random numbers, as opposed to hashing. See
[Wikipedia on Uuids](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29)
for more details). Version 4 Uuids are constructed using 122 pseudo random bits.

**Disclaimer**: If you use this Library to generate Uuids, please make sure to correctly
seed your random generator, as shown in the examples. **Don't** use the current time or something
similar to seed the generator. If your generator isn't seeded properly, the chance of a collision
between multiple clients is drastically increased!

Uuids can be generated either by parsing them from the canonical string representation
(see `fromString`) or by generating them. If you are unfamiliar with random number generation
in pure functional languages, this can be a bit confusing. The gist of it is that:

1.  you need a good random seed and this has to come from outside our wonderfully
    predictable Elm code (meaning you have to create an incoming port and feed in
    some initial randomness)

2.  every call to `generate` will give you a tuple of a Uuid and a new
    seed. It is very important that whenever you generate a new Uuid you store this
    seed you get back into your model and use this one for the next Uuid generation.
    If you reuse a seed, you will create the same Uuid twice!

Have a look at the examples in the package to see how to use it!

@docs Uuid, generator, fromString, toString, encode, decoder


## Barebones

@docs stringGenerator, isValidUuid

-}

import Random.Pcg.Extended exposing (Generator, map, list, int, step, Seed)
import String
import Uuid.Barebones exposing (..)
import Json.Decode as JD
import Json.Encode as JE


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
        Just <| Uuid <| String.toLower text
    else
        Nothing


{-| Random.Pcg.Extended generator for Uuids.

To provide enough randomness, you should seed this generator with at least 4 32-bit integers
that are aquired from JavaScript via `crypto.getRandomValues(...)`.
See the examples on how to do this properly.

-}
generator : Generator Uuid
generator =
    map Uuid stringGenerator


{-| Encode Uuid to Json
-}
encode : Uuid -> JE.Value
encode =
    toString
        >> JE.string


{-| Decoder for getting Uuid out of Json
-}
decoder : JD.Decoder Uuid
decoder =
    JD.string
        |> JD.andThen
            (\string ->
                case fromString string of
                    Just uuid ->
                        JD.succeed uuid

                    Nothing ->
                        JD.fail "Not a valid UUID"
            )


{-| Random.Pcg.Extended generator for Uuid Strings.
-}
stringGenerator : Generator String
stringGenerator =
    map toUuidString (list 31 hexGenerator)


{-| Check if the given string is a valid UUID
-}
isValidUuid : String -> Bool
isValidUuid =
    Uuid.Barebones.isValidUuid



-- Details


hexGenerator : Generator Int
hexGenerator =
    int 0 15
