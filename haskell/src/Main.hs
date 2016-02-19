module Main (main) where

import Criterion.Main

import qualified Chan
import qualified MVar
import qualified Parallel
import qualified Unagi

main :: IO ()
main = defaultMain
  [ bench "Unagi.Unboxed" $ whnfIO Unagi.main
  , bench "parallel" $ whnfIO Parallel.run -- 51 ms
  , bench "MVar" $ whnfIO MVar.run -- 2.2 s
  , bench "Chan" $ whnfIO Chan.run
  ]
