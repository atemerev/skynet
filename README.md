# Skynet 1M concurrency microbenchmark

Creates an actor (goroutine, whatever), which spawns 10 new actors, each of them spawns 10 
more actors, etc. until one million actors are created on the final level. Then, each of them returns
back its ordinal number (from 0 to 999999), which are summed on the previous level and sent back upstream,
until reaching the root actor. (The answer should be 499999500000).

## Results (on my shitty Macbook 12" '2015, **Core M**, OS X): 

- Scala/Akka: 33618 ms.
- Haskell (GHC 7.10.3): 6181 ms.
- Erlang (non-HIPE): 4414 ms.
- Erlang (HIPE): 3999 ms.
- Go: 979 ms.
- .NET Core: Async (8 threads) 650 ms / Sync (1 thread) 232 ms

## Results (**i7-4770**, Win8.1): 

- Scala/Akka: OOM :(
- Haskell (GHC 7.10.3): 2820 ms.
- Erlang (non-HIPE): 1700 ms.
- Go: 629 ms.
- .NET Core: Async (8 threads) 290 ms / Sync (1 thread) 49 ms.
- Node-bluebird (Promise) 285ms / 195ms (after warmup)

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

Then, run:

`skynet:skynet(1000000,10).`

### .NET Core: 

Install latest version of .NET Core

Go to `dnx/`  
`dotnet restore` (first time)  
`dotnet run`

### Haskell

Install the GHC compiler

In `haskell/`, run `ghc -O2 -o skynet Skynet.hs` then `./skynet`

### Node (bluebird)

Install node.js

in `node-bluebird/` run `npm install` then `node skynet`
