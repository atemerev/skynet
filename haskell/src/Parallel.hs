{-# LANGUAGE BangPatterns #-}
module Parallel (run) where

import Data.Time.Clock (getCurrentTime, diffUTCTime)

import Control.Parallel.Strategies

skynet :: Int -> Int -> Int -> Int
skynet num size dv
    | size == 1 = num
    | otherwise = sum (parMap rpar subcompute [0 .. dv-1])
    where
        subcompute i = let subNum  = num + i * sizeDiv
                           sizeDiv = size `quot` dv
                       in  skynet subNum sizeDiv dv
run :: IO ()
run = do
    start  <- getCurrentTime
    let !result = skynet 1 1000000 10
    end    <- getCurrentTime
    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]
