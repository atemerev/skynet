import java.util.ArrayList;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.stream.IntStream;
import java.util.stream.LongStream;

public class VirtualThreads {
  public VirtualThreads() {
    // Warm up to get more consistent results when timing.
    IntStream.of(0, 5)
        .forEach(i -> {
          skynetFixedWorkStealingPool();
          skynetVirtual();
          skynetCachedPool();
          skynetPlatform(); // dies with OOM at 100k
        });
  }

  public static void run() {

    Skynet.time("Fixed Work Stealing Pool", () -> skynetFixedWorkStealingPool());
    Skynet.time("Virtual Thread per task", () -> skynetVirtual());
    Skynet.time("Cached Pool", () -> skynetCachedPool());
    Skynet.time("Platform Thread per task, 1/100th size", () -> skynetPlatform()); // dies with OOM at 100k threads
  }

  private static Long skynetVirtual() {
    try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
      Future<Long> result = executor.submit(() -> skynet(0L, 1000000, 10, executor));
      return result.get();
    } catch (InterruptedException | ExecutionException e) {
      throw new RuntimeException(e);
    }
  }

  private static Long skynetFixedWorkStealingPool() {
    try (var executor = Executors.newWorkStealingPool()) {
      Future<Long> result = executor.submit(() -> skynet(0L, 1000000, 10, executor));
      return result.get();
    } catch (InterruptedException | ExecutionException e) {
      throw new RuntimeException(e);
    }
  }

  private static Long skynetCachedPool() {
    try (var executor = Executors.newCachedThreadPool()) {
      Future<Long> result = executor.submit(() -> skynet(0L, 1000000, 10, executor));
      return result.get();
    } catch (InterruptedException | ExecutionException e) {
      throw new RuntimeException(e);
    }
  }

  private static Long skynetPlatform() {
    try (var executor = Executors.newThreadPerTaskExecutor(Executors.defaultThreadFactory())) {
      Future<Long> result = executor.submit(() -> skynet(0L, 10000, 10, executor));
      return result.get();
    } catch (InterruptedException | ExecutionException e) {
      throw new RuntimeException(e);
    }
  }


  private static Long skynet(Long num, int size, int div, ExecutorService executor) throws ExecutionException, InterruptedException {
    if (size == 1) {
      return num;
    }

    ArrayList<Future<Long>> futures = new ArrayList<>();
    for (var i : LongStream.range(0, div).map(i -> i).toArray()) {
      Long subNum = num + (int) i * (size / div);
      futures.add(executor.submit(() -> skynet(subNum, size / div, div, executor)));
    }
    Long sum = 0L;
    for (var f : futures) {
      sum += f.get();
    }
    return sum;
  }
}
