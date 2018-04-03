# Elm Uuid
**This is a Fork** from [danyx23/elm-uuid](https://github.com/danyx23/elm-uuid).
It uses the [PCG-extended](http://package.elm-lang.org/packages/Zinggi/elm-random-pcg-extended/latest) PRNG to [provide enough randomness when generating UUIDs on different clients](https://github.com/danyx23/elm-uuid/issues/10).

---

This modules provides an opaque type for Uuids, helpers to serialize
from and to String and helpers to generate new Uuids.

Uuids are Universally Unique IDentifiers. They are 128 bit ids that are
designed to be extremely unlikely to collide with other Uuids.

This library only supports generating Version 4 Uuid (those generated using
random numbers, as opposed to hashing. See
[Wikipedia on Uuids](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29)
for more details).


Check out the [example](https://github.com/Zinggi/elm-uuid/tree/master/examples) to see how this works in practice


Package originally by Daniel Bachler
