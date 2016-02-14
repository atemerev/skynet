{-# LANGUAGE ViewPatterns #-}

module Main (main) where

import           Control.Applicative
import           Control.Concurrent.Async
import           Data.Time.Clock          (diffUTCTime, getCurrentTime)

worker :: Int -> Int -> Int -> IO Int
worker num size dv
    | size == 1 = return num
    | otherwise = sum <$> mapConcurrently mkChild [0..dv-1]
  where
    sizeDiv = size `quot` dv
    subNum i = num + i * sizeDiv
    mkChild (subNum -> n) = worker n sizeDiv dv

main :: IO ()
main = do
    start  <- getCurrentTime
    result <- wait =<< async (worker 0 1000000 10)
    end    <- getCurrentTime

    putStrLn $ concat ["Result: ", show result, " in ", show (diffUTCTime end start)]
