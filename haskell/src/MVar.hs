{-# LANGUAGE BangPatterns #-}

module MVar (run) where

import Control.Concurrent (forkIO)
import Control.Concurrent.MVar (MVar, newEmptyMVar, putMVar, takeMVar)
import Control.Monad (forM, foldM)
import Data.Time.Clock (getCurrentTime, diffUTCTime)

plus1 :: Int -> MVar Int -> IO Int
plus1 !n rc = do
    n' <- takeMVar rc
    return $ n + n' 

forkSkynet :: Int -> Int -> Int -> IO (MVar Int)
forkSkynet !num !size !div = do
            rc <- newEmptyMVar
            _ <- forkIO $ skynet rc num size div
            return rc

skynet :: MVar Int -> Int -> Int -> Int -> IO ()
skynet c !num     1 div = putMVar c num
skynet c !num !size div = let sizeDiv = size `quot` div in do
        rcs <- forM [0..div-1] (\i -> let subNum  = num + i * sizeDiv in
            forkSkynet subNum sizeDiv div)
        result <- foldM plus1 0 rcs
        putMVar c result

run :: IO ()
run = do
    start  <- getCurrentTime
    c      <- forkSkynet 0 1000000 10
    result <- takeMVar c
    end    <- getCurrentTime
    putStrLn $ concat [ "Result: "
                      , show result
                      , " in "
                      , show (diffUTCTime end start) ]
