{-# LANGUAGE BangPatterns #-}

module MVar (run) where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Monad (forM, foldM)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

children = 10

plus1 :: Int -> MVar Int -> IO Int
plus1 !n !rc = do
    n' <- takeMVar rc
    return $ n + n' 

forkSkynet :: Int -> Int -> IO (MVar Int)
forkSkynet !lvl !num = do
            rc <- newEmptyMVar
            _  <- forkIO $ skynet rc lvl num
            return rc

skynet :: MVar Int -> Int -> Int -> IO ()
skynet c    0 !num = putMVar c num
skynet c !lvl !num = let
    !numFirst = num      * children
    !numLast  = numFirst + children - 1
    !lvl1     = lvl - 1
    in do
        rcs <- forM [numFirst..numLast] $ forkSkynet lvl1
        result <- foldM plus1 0 rcs
        putMVar c result

run :: IO ()
run = do
    start  <- getCurrentTime
    c      <- forkSkynet 6 0
    result <- takeMVar c
    end    <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show (diffUTCTime end start) ]
