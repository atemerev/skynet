import Control.Concurrent
import Control.Concurrent.MVar
import Control.Monad
import Data.Time.Clock
import Text.Printf

spawn :: (a -> IO ()) -> a -> IO a
spawn f x = forkIO (f x) >> return x

skynet :: Int -> Int -> Int -> MVar Int -> IO ()
skynet num 1    _    chan = putMVar chan num
skynet num size part chan =
    mapM job [0 .. pred part] >>= (fmap sum . mapM takeMVar) >>= putMVar chan
  where
    job i = newEmptyMVar >>= spawn (skynet (num + i * sd) sd part)
      where
        sd = size `div` part

run :: IO ()
run = do
  start  <- getCurrentTime
  result <- newEmptyMVar >>= spawn (skynet 0 1000000 10) >>= takeMVar
  end    <- getCurrentTime
  printf "Result: %d in %s\n" result (show $ diffUTCTime end start)

main :: IO ()
main = forM_ [1..10] (const run)
