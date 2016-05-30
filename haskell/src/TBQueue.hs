{-# LANGUAGE BangPatterns #-}

module TBQueue (run) where

import Control.Concurrent             (forkIO)
import Control.Concurrent.STM         (atomically)
import Control.Concurrent.STM.TBQueue (TBQueue, newTBQueueIO, writeTBQueue, readTBQueue)
import Control.Monad                  (forM_, replicateM)
import Data.Time.Clock                (getCurrentTime, diffUTCTime)

children = 10

skynet :: TBQueue Int -> Int -> Int -> IO ()
skynet q    0 !num = atomically $ writeTBQueue q num
skynet q !lvl !num = let
    !numFirst = num      * children
    !numLast  = numFirst + children - 1
    !lvl1     = lvl - 1
    in do
        tbq <- newTBQueueIO 11
        forM_ [numFirst..numLast] $ forkIO . skynet tbq lvl1
        sum <- atomically $ sum <$> replicateM children (readTBQueue tbq)
        atomically $ writeTBQueue q sum

run :: IO ()
run = do
    start  <- getCurrentTime
    tbq <- newTBQueueIO 11
    _      <- forkIO $ skynet tbq 6 0
    result <- atomically $ readTBQueue tbq
    end    <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show $ diffUTCTime end start
                      ]
