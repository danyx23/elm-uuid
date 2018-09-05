module Tests exposing (all)

--import Check exposing (claim, claimTrue, that, is, true, false, for, quickCheck)
--import Check.Test exposing (evidenceToTest)

import Expect
import Fuzz
import Random exposing (initialSeed, step)
import String
import Test exposing (..)
import Uuid exposing (..)
import Uuid.Barebones exposing (..)


buildUuid integer =
    let
        initialSeed =
            Random.initialSeed integer

        ( uuid, seed ) =
            step uuidGenerator initialSeed
    in
    uuid


initialSeedFuzzer =
    Fuzz.map Random.initialSeed Fuzz.int


uuidFuzzer =
    Fuzz.map buildUuid Fuzz.int


all : Test
all =
    describe "All tests"
        [ test "isValid - for valid uuid" <|
            \() ->
                "63B9AAA2-6AAF-473E-B37E-22EB66E66B76"
                    |> isValidUuid
                    |> Expect.true "should be valid"
        , test "isValid - for invalid uuid" <|
            \() ->
                "zz"
                    |> isValidUuid
                    |> Expect.false "should be invalid"
        , fuzz initialSeedFuzzer "generate uuid" <|
            \initialSeed ->
                let
                    ( uuid, nextSeed ) =
                        step uuidGenerator initialSeed
                in
                uuid
                    |> Uuid.toString
                    |> isValidUuid
                    |> Expect.true "should be valid uuid"
        , fuzz initialSeedFuzzer "generate two uuids" <|
            \initialSeed ->
                let
                    ( uuid1, seed1 ) =
                        step uuidGenerator initialSeed

                    ( uuid2, seed2 ) =
                        step uuidGenerator seed1
                in
                Expect.notEqual uuid1 uuid2
        , fuzz uuidFuzzer "roundtripping uuid through toString -> fromString keeps the Uuids intact" <|
            \uuid ->
                uuid
                    |> Uuid.toString
                    |> Uuid.fromString
                    |> Expect.equal (Just uuid)
        , fuzz uuidFuzzer "roundtripping uuid through toString -> fromString keeps the Uuids intact - upper casing is ignored" <|
            \uuid ->
                uuid
                    |> Uuid.toString
                    |> String.toUpper
                    |> Uuid.fromString
                    |> Expect.equal (Just uuid)
        , fuzz uuidFuzzer "roundtripping uuid through toString -> fromString keeps the Uuids intact - lower casing is ignored" <|
            \uuid ->
                uuid
                    |> Uuid.toString
                    |> String.toLower
                    |> Uuid.fromString
                    |> Expect.equal (Just uuid)
        ]
