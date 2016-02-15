-- Compile: ghc -threaded -rtsopts -O2 -o skynet Skynet.hs
-- Run:     ./skynet +RTS -N8 -H7G -RTS
-- Use system dependent -H (heap) and -N (cpus)

module Main (main) where

import Control.Parallel.Strategies (parMap, rseq)
import Control.Monad            (forM, replicateM_, void)
import Data.Time.Clock          (getCurrentTime, diffUTCTime)

skynet :: Int -> Int -> Int
skynet levels children = sky levels 0
    where
        childnums = [0..children-1]
        sky 0   position = position
        sky lvl position = sum $ parMap rseq (\cn -> sky (lvl-1) $ position*children + cn) childnums

doRun :: IO ()
doRun = do
    start  <- getCurrentTime
    let result = skynet 6 10
    end    <- result `seq` getCurrentTime
    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]

main :: IO ()
main = void (replicateM_ 10 doRun)
