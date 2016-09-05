module Tests exposing (..)

--import Check exposing (claim, claimTrue, that, is, true, false, for, quickCheck)
--import Check.Test exposing (evidenceToTest)

import Test exposing (..)
import String
import Expect
import Uuid.Barebones exposing (..)
import Uuid exposing (..)
import Random.Pcg exposing (step, initialSeed)
import Random
import Fuzz
import Shrink


randomInt =
    Random.Pcg.int Random.Pcg.minInt Random.Pcg.maxInt


buildUuid integer =
    let
        initialSeed =
            Random.Pcg.initialSeed integer

        ( uuid, seed ) =
            step uuidGenerator initialSeed
    in
        uuid


initialSeedFuzzer =
    Fuzz.custom
        (randomInt |> Random.Pcg.map Random.Pcg.initialSeed)
        Shrink.noShrink


uuidFuzzer =
    Fuzz.custom (randomInt |> Random.Pcg.map buildUuid) Shrink.noShrink


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
