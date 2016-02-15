{-# LANGUAGE BangPatterns #-}

module MVar (run) where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Monad (forM)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

skynet :: MVar Int -> Int -> Int -> Int -> IO ()
skynet c !num !size div
    | size == 1 = putMVar c num
    | otherwise = do
        rcs <- forM [0..div-1] (\i -> do
            rc <- newEmptyMVar
            let subNum  = num + i * sizeDiv
                sizeDiv = size `quot` div
            _ <- forkIO (skynet rc subNum sizeDiv div)
            return rc )
        result <- loop1 rcs 0
        putMVar c result

loop1 :: [MVar Int] -> Int -> IO Int
loop1  []      !n = return n
loop1 (rc:rcs) !n = do
    n' <- takeMVar rc
    loop1 rcs (n + n')

run :: IO ()
run = do
    c      <- newEmptyMVar
    start  <- getCurrentTime
    _      <- forkIO (skynet c 1 1000000 10)
    result <- takeMVar c
    end    <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show (diffUTCTime end start) ]
