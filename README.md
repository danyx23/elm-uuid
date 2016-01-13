#Elm Uuid

This modules provides an opaque type for Uuids, helpers to serialize
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

This library is split into two Modules. Uuid wraps Uuids in
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

Check out the example to see how this works in practice

by Daniel Bachler