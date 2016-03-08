{-# LANGUAGE BangPatterns #-}
module Parallel (run) where

import Control.Parallel.Strategies (parMap, rpar)
import Data.Time.Clock             (getCurrentTime, diffUTCTime)

children = 10

skynet :: Int -> Int -> Int
skynet   0  !num =  num
skynet !lvl !num = let
    !numFirst = num      * children
    !numLast  = numFirst + children - 1
    !lvl1     = lvl - 1
    in sum $ parMap rpar (skynet lvl1) [numFirst..numLast]

run :: IO ()
run = do
    start      <- getCurrentTime
    let !result = skynet 6 0
    end        <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show $ diffUTCTime end start
                      ]
