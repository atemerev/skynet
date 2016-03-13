module Main (main) where

import Criterion.Main     (defaultMain, bench, whnfIO)
import GHC.Stats          (getGCStats, getGCStatsEnabled)

import qualified Chan     (run)
import qualified MVar     (run)
import qualified Parallel (run)
import qualified TBQueue  (run)
import qualified Unagi    (run)

-- time given for a system: i7-4930K CPU @ 3.40GHz, six cores
-- run with +RTS -N6
implList :: [(String, IO ())]
implList = [ ("Parallel", Parallel.run) -- 0.017 s
           , ("MVar"    ,     MVar.run) -- 1.7 s
           , ("Chan"    ,     Chan.run) -- 1.8 s
           , ("TBQueue" ,  TBQueue.run) -- 6.8 s
           , ("Unagi"   ,    Unagi.run) -- 15  s
           ]


measureTime :: IO ()
measureTime  = defaultMain $ map bench1 implList
    where
    bench1 (name, run) = bench name $ whnfIO run

measureMemory :: IO ()
measureMemory  = sequence_ $ map run'stats implList
    where
    run'stats (name, run) = do
        putStrLn name
        run
        stats <- getGCStats
        putStrLn $ show1 stats
        putStrLn ""
    show1 x = map comma2nl $ show x
    comma2nl ',' = '\n'
    comma2nl c   = c

main :: IO ()
main = do
    memory <- getGCStatsEnabled -- true if +RTS -T
    let measure = if memory then measureMemory else measureTime
    measure
