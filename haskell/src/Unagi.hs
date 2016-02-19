module Unagi (main) where

import Control.Concurrent (forkIO)
import Control.Concurrent.Chan.Unagi.Unboxed (InChan, newChan, writeChan, readChan)
import Control.Monad (forM_, replicateM)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

skynet :: InChan Int -> Int -> Int -> Int -> IO ()
skynet c num size div'
    | size == 1 = writeChan c num
    | otherwise = do
          (inChan, outChan) <- newChan
          forM_ [0..div'-1] $ \i -> do
              let subNum  = num + i * sizeDiv
                  sizeDiv = size `quot` div'
              forkIO $ skynet inChan subNum sizeDiv div'
          sum' <- sum <$> replicateM div' (readChan outChan)
          writeChan c sum'

main :: IO ()
main = do
    (inChan, outChan) <- newChan
    start  <- getCurrentTime
    _      <- forkIO $ skynet inChan 0 1000000 10
    result <- readChan outChan
    end    <- getCurrentTime
    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]
