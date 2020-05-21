# Elm Uuid

**Note:** this package has been forked with a few updates for 0.19 and is now maintained at: https://package.elm-lang.org/packages/NoRedInk/elm-uuid/2.0.0/

This package provides an opaque type for Uuids, helpers to serialize
from and to String and helpers to generate new Uuids using Elm's
[Random](https://package.elm-lang.org/packages/elm/random/latest/) package.

Uuids are Universally Unique IDentifiers. They are 128 bit ids that are
designed to be extremely unlikely to collide with other Uuids.

This library only supports generating Version 4 Uuid (those generated using
random numbers, as opposed to hashing. See
[Wikipedia on Uuids](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29)
for more details). Version 4 Uuids are constructed using 122 pseudo random bits.

Disclaimer: If you use this Library to generate Uuids, please be advised
that it does not use a cryptographically secure pseudo random number generator.
Depending on your use case the randomness provided may not be enough. The
period of the underlying random generator is high, so creating lot's of random
UUIDs on one client is fine, but please be aware that since the initial random
seed of the current Random implementation is limited to 32 bits, creating
UUIDs on *many independent clients* may lead to collisions more quickly than you
think (see https://github.com/danyx23/elm-uuid/issues/10 for details)! If you need
to generate UUIDs on many clients independently, please use the fork https://package.elm-lang.org/packages/Zinggi/elm-uuid/latest which covers this case.

This library is split into two Modules. Uuid wraps Uuids in
an opaque type for improved type safety. If you prefer to simply get strings
you can use the Uuid.Barebones module which provides methods to generate
and verify Uuid as plain Strings.

Uuids can be generated either by parsing them from the canonical string representation
(see fromString) or by generating them. If you are unfamiliar with random number generation
in pure functional languages, this can be a bit confusing. The gist of it is that:

1. you need a good random seed and this has to come from outside our wonderfully
predictable Elm code (meaning you have to either use programWithFlags and pass in
initial random seeds or alternatively use the Core.Random generate Cmd introduced
with Elm 0.17 to get random values)

2. every call to generate a new Uuid will give you a tuple of a Uuid and a new
seed. It is very important that whenever you generate a new Uuid you store this
seed you get back into your model and use this one for the next Uuid generation.
If you reuse a seed, you will create the same Uuid twice!

Check out the example to see how this works in practice

[![Build Status](https://travis-ci.org/danyx23/elm-uuid.svg?branch=master)](https://travis-ci.org/danyx23/elm-uuid)

by Daniel Bachler
