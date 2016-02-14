-- | Results of the old vs. new code on a Core i7 Linux Laptop.
--
-- Compile w/ `ghc -O skynet.hs` for optimized code.
--
-- OLD Result: 499999500000 in 3.07968s
-- NEW Result: 499999500000 in 0.617s

{-# LANGUAGE ViewPatterns #-}

module Main (main) where

import           Control.Applicative
import           Control.Concurrent.Async
import           Control.Monad            (forM)
import           Data.Time.Clock          (diffUTCTime, getCurrentTime)

supervisor :: Int -> Int -> Int -> IO Int
supervisor n s d = wait =<< async (worker n s d)

worker :: Int -> Int -> Int -> IO Int
worker num size dv
    | size == 1 = return num
    | otherwise = sum <$> forM [0..dv-1] spawnChild
  where
    sizeDiv = size `quot` dv
    subNum i = num + i * sizeDiv
    spawnChild (subNum -> n) = supervisor n sizeDiv dv

main :: IO ()
main = do
    start  <- getCurrentTime
    result <- supervisor 0 1000000 10
    end    <- getCurrentTime

    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]
