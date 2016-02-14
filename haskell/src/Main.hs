module Main (main) where

import Criterion.Main

import qualified Chan
import qualified Parallel

main :: IO ()
main = defaultMain
  [ bench "chan" $ whnfIO Chan.run
  , bench "parallel" $ whnfIO Parallel.run
  ]
