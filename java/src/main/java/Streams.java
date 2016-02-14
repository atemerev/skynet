import java.util.stream.IntStream;
import java.util.stream.LongStream;

public class Streams {
  public Streams() {
    // Warm up to get more consistent results when timing.
    IntStream.of(0, 5)
        .forEach(i -> {
          skynet(false);
          skynet(true);
        });
  }

  public void run() {
    run(false);
    run(true);
  }

  private static void run(boolean parallel) {
    Skynet.time(parallel ? "parallel" : "sequential", () -> skynet(parallel));
  }

  private static long skynet(boolean parallel) {
    return skynet(parallel, 0, 1000000, 10);
  }

  private static long skynet(boolean parallel, int num, int size, int div) {
    if (size == 1) {
      return num;
    }

    LongStream stream = LongStream.range(0, div)
        .map(i -> {
          int subNum = num + (int) i * (size / div);
          return skynet(parallel, subNum, size / div, div);
        });

    if (parallel) {
      stream = stream.parallel();
    }

    return stream.sum();
  }
}
