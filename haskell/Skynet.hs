-- Compile: ghc -threaded -rtsopts -O2 -o skynet Skynet.hs
-- Run:     ./skynet +RTS -N8 -H7G -RTS
-- Use system dependent -H (heap) and -N (cpus)

module Main (main) where

import Control.Concurrent.Async (async, wait)
import Control.Monad            (forM, replicateM_, void)
import Data.Time.Clock          (getCurrentTime, diffUTCTime)

skynet :: Int -> Int -> Int -> IO Int
skynet num size cnt
  | size == 1 = return num
  | otherwise = do
      kids <- spawnNKids (cnt - 1)
      rs   <- mapM wait kids
      return (sum rs)
 where
   spawnKid i = async (skynet subNum sizeDiv cnt)
     where subNum = num + i * sizeDiv
           sizeDiv = size `quot` cnt
   spawnNKids n = forM [0..n] spawnKid

doRun :: IO ()
doRun = do
    start  <- getCurrentTime
    t      <- async (skynet 0 1000000 10)
    result <- wait t
    end    <- getCurrentTime
    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]

main :: IO ()
main = void (replicateM_ 10 doRun)
