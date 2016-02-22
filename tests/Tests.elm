module Tests where

import ElmTest exposing (..)
import String
import Uuid.Barebones exposing (..)

 
all : Test
all = 
    suite "A Test Suite"
        [ 
            test "isValid of valid uuid" (assert (isValidUuid "63B9AAA2-6AAF-473E-B37E-22EB66E66B76"))
        ,   test "isValid of invalid uuid 1" (assert (not <| isValidUuid "a63B9AAA2-6AAF-473E-B37E-22EB66E66B76"))
        ,   test "isValid of invalid uuid 2" (assert (not <| isValidUuid "63B9AAA2-6AAF-F73E-B37E-22EB66E66B76"))
        ] 
