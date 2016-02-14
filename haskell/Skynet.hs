module Main (main) where

import Control.Concurrent (forkIO)
import Control.Concurrent.Chan (Chan, newChan, writeChan, readChan)
import Control.Monad (forM_, replicateM)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

skynet :: Chan Int -> Int -> Int -> Int -> IO ()
skynet c num size div
    | size == 1 = writeChan c num
    | otherwise = do
          rc <- newChan
          forM_ [0..div-1] $ \i -> do
              let subNum  = num + i * sizeDiv
                  sizeDiv = size `quot` div
              forkIO $ skynet rc subNum sizeDiv div
          sum <- sum <$> replicateM div (readChan rc)
          writeChan c sum

main :: IO ()
main = do
    c      <- newChan
    start  <- getCurrentTime
    _      <- forkIO $ skynet c 0 1000000 10
    result <- readChan c
    end    <- getCurrentTime
    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]
