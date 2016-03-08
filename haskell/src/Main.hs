module Main (main) where

import Criterion.Main

import qualified Chan
import qualified MVar
import qualified Parallel
import qualified TBQueue

main :: IO ()
main = defaultMain
  [ bench "parallel" $ whnfIO Parallel.run --    51 ms
  , bench "MVar"     $ whnfIO     MVar.run -- 2.2 s
  , bench "Chan"     $ whnfIO     Chan.run -- 2.2 s
  , bench "TBQueue"  $ whnfIO  TBQueue.run --     s
  ]
