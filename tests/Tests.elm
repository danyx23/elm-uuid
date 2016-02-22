module Tests where

import Check exposing (claim, claimTrue, that, is, true, false, for, quickCheck)
import Check.Test exposing (evidenceToTest)
import Check.Investigator exposing (int)
import ElmTest exposing (..)
import String
import Uuid.Barebones exposing (..)
import Uuid exposing (..)
import Random.PCG exposing (generate, initialSeed)
import Random
import Shrink
import Check.Investigator exposing (shrink, random, Investigator)

uuidFromSeed : Int -> Uuid
uuidFromSeed seed =
  initialSeed seed 
    |> generate uuidGenerator
    |> fst

uuidInvestigator : Investigator Uuid
uuidInvestigator =
  let
      generator =
        Random.map uuidFromSeed (random int)
  in
      Investigator generator Shrink.noShrink


claim_generated_uuid_strings_are_valid =
  claim
    "Generated Uuids are valid"
  `true`
    (\uuid -> Uuid.toString uuid
            |> isValidUuid)
  `for`
    uuidInvestigator

claim_toString_fromString_roundtripping_works =
  claim
    "Rount-tripping Uuids through toString -> fromString keeps the Uuids intact"
  `that`
    (Uuid.toString >> Uuid.fromString)
  `is`
    (\x -> Just x)
  `for`
    uuidInvestigator

claim_toString_fromString_roundtripping_works_with_uppercase =
  claim
    "Rount-tripping Uuids through toString -> fromString keeps the Uuids intact, uppercasing is ignored"
  `that`
    (Uuid.toString >> String.toUpper >> Uuid.fromString)
  `is`
    (\x -> Just x)
  `for`
    uuidInvestigator

claim_toString_fromString_roundtripping_works_with_lowercase =
  claim
    "Rount-tripping Uuids through toString -> fromString keeps the Uuids intact, uppercasing is ignored"
  `that`
    (Uuid.toString >> String.toLower >> Uuid.fromString)
  `is`
    (\x -> Just x)
  `for`
    uuidInvestigator

testSuite = 
  Check.suite "Quickcheck test suite 1"
  [ claim_generated_uuid_strings_are_valid 
  , claim_toString_fromString_roundtripping_works
  , claim_toString_fromString_roundtripping_works_with_uppercase
  , claim_toString_fromString_roundtripping_works_with_lowercase
  ]

result : Check.Evidence
result = quickCheck testSuite

quickCheckSuite : ElmTest.Test
quickCheckSuite = ElmTest.suite "Quickcheck suite"
    [evidenceToTest result]   

unitTestSuite = 
  suite "Unit test suite"
        [   test "isValid of valid uuid" (assert (isValidUuid "63B9AAA2-6AAF-473E-B37E-22EB66E66B76"))
        ,   test "isValid of invalid uuid 1" (assert (not <| isValidUuid "a63B9AAA2-6AAF-473E-B37E-22EB66E66B76"))
        ,   test "isValid of invalid uuid 2" (assert (not <| isValidUuid "63B9AAA2-6AAF-F73E-B37E-22EB66E66B76"))
        ] 
 
all : Test
all = 
    suite "All tests"
    [ unitTestSuite
    , quickCheckSuite
    ]
