# Skynet 1M concurrency microbenchmark

Creates an actor (goroutine, whatever), which spawns 10 new actors, each of them spawns 10 
more actors, etc. until one million actors are created on the final level. Then, each of them returns
back its ordinal number (from 0 to 999999), which are summed on the previous level and sent back upstream,
until reaching the root actor. (The answer should be 499999500000).

## Results (on my shitty Macbook 12" '2015): 

- Scala/Akka: 33618 ms.
- Erlang (non-HIPE): 4414 ms.
- Erlang (HIPE): 3999 ms.
- Go: 979 ms.

## How to run

### Scala/Akka

Install latest Scala and SBT. 

Go to `scala/`, then run `sbt`, then `compile`, then `run`.

### Go

Install latest Go compiler/runtime.

In `go/`, run `go run skynet.go`.

### Erlang

Install latest Erlang runtime.

In `erlang`, run `erl +P 2000000` (to raise process limit), then compile:

- For non-HIPE: `c(skynet).`
- For HIPE (if supported on your system): `hipe:c(skynet).`

### Haskell

Install the GHC compiler

In `haskell/`, run `runhaskell Skynet.hs` or `ghc -o skynet Skynet.hs`
