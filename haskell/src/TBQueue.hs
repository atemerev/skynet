-- this needs fixed still
module Main (main) where

import Control.Concurrent (forkIO)
import Control.Concurrent.Chan (Chan, newChan, writeChan, readChan)
-- import Control.Concurrent.Chan.Unagi (InChan, OutChan, newChan, writeChan, readChan)
-- import Control.Concurrent.STM (atomically)
-- import Control.Concurrent.STM.TBQueue (TBQueue, newTBQueueIO, writeTBQueue, readTBQueue)
import Control.Monad (forM_, replicateM)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

skynet :: TBQueue Int -> Int -> Int -> Int -> IO ()
skynet q num size div
    | size == 1 = atomically $ writeTBQueue q num
    | otherwise = do
          tbq <- newTBQueueIO 1000001
          forM_ [0..div-1] $ \i -> do
              let subNum  = num + i * sizeDiv
                  sizeDiv = size `quot` div
              forkIO $ skynet tbq subNum sizeDiv div
          sum <- atomically $ sum <$> replicateM div (readTBQueue tbq)
          atomically $ writeTBQueue q sum

main :: IO ()
main = do
    tbq <- newTBQueueIO 1000001
    start  <- getCurrentTime
    _      <- forkIO $ skynet tbq 1 1000000 10
    result <- atomically $ readTBQueue tbq
    end    <- getCurrentTime
    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]
