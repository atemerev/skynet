import rx.functions.Func0;

import java.time.Duration;
import java.time.Instant;

public class Skynet {
  public static void main(String[] args) {
    // Allow each strategy to warm itself up to generate more consistent results.
    Streams streams = new Streams();
    Rx rx = new Rx();
    VirtualThreads virtualThreads = new VirtualThreads();

    System.out.println("Streams");
    System.out.println("-------");
    streams.run();
    System.out.println();

    System.out.println("VirtualThreads");
    System.out.println("-------");
    virtualThreads.run();
    System.out.println();

    System.out.println("RxJava");
    System.out.println("------");
    rx.run();
  }

  public static void time(String description, Func0<Long> calculateResult) {
    Instant start = Instant.now();
    long result = calculateResult.call();
    Duration duration = Duration.between(start, Instant.now());
    System.out.printf("Result: %d in %d ms. (%s)\n",
        result, duration.toMillis(), description);
  }
}
