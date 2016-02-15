module Main (main) where

import Criterion.Main

import qualified Chan
import qualified MVar
import qualified Parallel

main :: IO ()
main = defaultMain
  [ bench "parallel" $ whnfIO Parallel.run -- 51 ms
  -- , bench "MVar" $ whnfIO MVar.run -- 2.2 s
  ]
