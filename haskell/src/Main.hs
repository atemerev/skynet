module Main (main) where

import Criterion.Main

import qualified Chan
import qualified MVar
import qualified Parallel
import qualified TBQueue
import qualified Unagi

main :: IO ()
main = defaultMain  -- i7-4930K CPU @ 3.40GHz, six cores, +RTS -N6
    [ bench "parallel" $ whnfIO Parallel.run -- 0.017 s
    , bench "MVar"     $ whnfIO     MVar.run -- 1.7 s
    , bench "Chan"     $ whnfIO     Chan.run -- 1.8 s
    , bench "TBQueue"  $ whnfIO  TBQueue.run -- 6.8 s
    , bench "Unagi"    $ whnfIO    Unagi.run -- 15  s
    ]
