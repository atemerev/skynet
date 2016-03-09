module Main (main) where

import Criterion.Main     (defaultMain, bench, whnfIO)
import GHC.Stats          (getGCStats, getGCStatsEnabled)

import qualified Chan     (run)
import qualified MVar     (run)
import qualified Parallel (run)
import qualified TBQueue  (run)
import qualified Unagi    (run)

measureTime :: IO ()
measureTime  = defaultMain  -- i7-4930K CPU @ 3.40GHz, six cores, +RTS -N6
    [ bench "Parallel" $ whnfIO Parallel.run -- 0.017 s
    , bench "MVar"     $ whnfIO     MVar.run -- 1.7 s
    , bench "Chan"     $ whnfIO     Chan.run -- 1.8 s
    , bench "TBQueue"  $ whnfIO  TBQueue.run -- 6.8 s
    , bench "Unagi"    $ whnfIO    Unagi.run -- 15  s
    ]

measureMemory :: IO ()
measureMemory = do
    putStrLn "on start"
    stats0 <- getGCStats
    putStrLn $ show stats0
    putStrLn ""
    putStrLn "Parallel"
    Parallel.run
    stats1 <- getGCStats
    putStrLn $ show stats1
    putStrLn ""
    putStrLn "MVar"
    MVar.run
    stats2 <- getGCStats
    putStrLn $ show stats2
    putStrLn ""
    putStrLn "Chan"
    Chan.run
    stats3 <- getGCStats
    putStrLn $ show stats3
    putStrLn ""
    putStrLn "TBQueue"
    TBQueue.run
    stats4 <- getGCStats
    putStrLn $ show stats4
    putStrLn ""
    putStrLn "Unagi"
    Unagi.run
    stats5 <- getGCStats
    putStrLn $ show stats5

main :: IO ()
main = do
    memory <- getGCStatsEnabled -- true if +RTS -T
    let measure = if memory then measureMemory else measureTime
    measure
