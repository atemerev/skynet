{-# LANGUAGE BangPatterns #-}

module Unagi (run) where

import Control.Concurrent            (forkIO)
import Control.Concurrent.Chan.Unagi (InChan, newChan, writeChan, readChan)
import Control.Monad                 (forM_, replicateM)
import Data.Time.Clock               (getCurrentTime, diffUTCTime)

children = 10

skynet :: InChan Int -> Int -> Int -> IO ()
skynet c    0 !num = writeChan c num
skynet c !lvl !num = let
    !numFirst = num      * children
    !numLast  = numFirst + children - 1
    !lvl1     = lvl - 1
    in do
        (inChan, outChan) <- newChan
        forM_ [numFirst..numLast] $ forkIO . skynet inChan lvl1
        result <- sum <$> replicateM children (readChan outChan)
        writeChan c result

run :: IO ()
run = do
    start  <- getCurrentTime
    (inChan, outChan) <- newChan
    _      <- forkIO $ skynet inChan 6 0
    result <- readChan outChan
    end    <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show $ diffUTCTime end start
                      ]
