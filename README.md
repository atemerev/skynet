[![Issue Stats](http://issuestats.com/github/atemerev/skynet/badge/pr   )](http://issuestats.com/github/atemerev/skynet)
[![Issue Stats](http://issuestats.com/github/atemerev/skynet/badge/issue)](http://issuestats.com/github/atemerev/skynet)

# Skynet 1M concurrency microbenchmark

Creates an actor (goroutine, whatever), which spawns 10 new actors, each of them spawns 10 
more actors, etc. until one million actors are created on the final level. Then, each of them returns
back its ordinal number (from 0 to 999999), which are summed on the previous level and sent back upstream,
until reaching the root actor. (The answer should be 499999500000).

## Results (on my shitty Macbook 12" '2015, **Core M**, OS X): 

### Actors

- Scala/Akka: 6379 ms. 
- Erlang (non-HIPE): 4414 ms.
- Erlang (HIPE): 3999 ms.

### Coroutines / fibers / channels

- Haskell (GHC 7.10.3): 6181 ms.
- Go: 979 ms.
- Quasar fibers and channels (Java 8): TODO

### Futures / promises

- .NET Core: 650 ms.
- RxJava: 219 ms.

## Results (**i7-4770**, Win8.1): 

### Actors

- Scala/Akka: 4419 ms
- Erlang (non-HIPE): 1700 ms.

### Coroutines / fibers / channels

- Haskell (GHC 7.10.3): 2820 ms.
- Go: 629 ms.
- F# MailboxProcessor: 756ms. (should be faster?..)
- Quasar fibers and channels (Java 8): TODO

### Futures / promises

- .NET Core: Async (8 threads) 290 ms
- Node-bluebird (Promise) 285ms / 195ms (after warmup)
- .NET Full (TPL): 118 ms.

## Results (**i7-4771**, Ubuntu 15.10): 

- Scala/Akka: 1700-2700 ms
- Haskell (GHC 7.10.3): 41-44 ms
- Erlang (non-HIPE): 700-1100 ms
- Erlang (HIPE): 2100-3500 ms
- Go: 200-224 ms
- LuaJit: 297 ms

## How to run

### Scala/Akka

Install latest Scala and SBT. 

Go to `scala/`, then run `sbt compile run`.

### Java/Quasar

Install the Java 8 SDK.

Go to `java-quasar/`
`./gradlew`

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
`dotnet run --configuration Release`

### Haskell

Install [Stack](http://haskellstack.org)

In `haskell/`, run `stack build && stack exec skynet +RTS -N`

### Node (bluebird)

Install node.js

in `node-bluebird/` run `npm install` then `node skynet`

### FSharp

Install FSharp Interactive

Run fsi skynet.fsx, or run fsi and paste the code in (runs faster this way)

### Crystal:

Install [latest version of Crystal](http://crystal-lang.org/docs/installation/index.html).

Go to `crystal/`
`crystal build skynet.cr --release`
`./skynet`

### .NET/TPL

Build the solution with VS2015. Windows only :(

=======
### Java

Install the Java 8 SDK.

Go to `java/`
`./gradlew :run`

### Rust (with [coroutine-rs](https://github.com/rustcc/coroutine-rs))

```bash
cd ./rust-coroutine
cargo build --release
cargo run --release
```

### LuaJIT

Install luajit

Run `luajit luajit/skynet.lua`

### Scheme/Guile Fibers

Install Guile, Guile fibers, and wisp; for example via `guix package -i guile guile-fibers guile-wisp`.

Go to `guile-fibers`
`./skynet.scm`
