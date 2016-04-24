{-# LANGUAGE BangPatterns #-}

module Chan (run) where

import Control.Concurrent      (forkIO)
import Control.Concurrent.Chan (Chan, newChan, writeChan, readChan)
import Control.Monad           (forM_, replicateM)
import Data.Time.Clock         (getCurrentTime, diffUTCTime)

children = 10

skynet :: Chan Int -> Int -> Int -> IO ()
skynet c    0 !num = writeChan c num
skynet c !lvl !num = let
    !numFirst = num      * children
    !numLast  = numFirst + children - 1
    !lvl1     = lvl - 1
    in do
        rc <- newChan
        forM_ [numFirst..numLast] $ forkIO . skynet rc lvl1
        result <- sum <$> replicateM children (readChan rc)
        writeChan c result

run :: IO ()
run = do
    start  <- getCurrentTime
    c      <- newChan
    _      <- forkIO $ skynet c 6 0
    result <- readChan c
    end    <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show $ diffUTCTime end start
                      ]
