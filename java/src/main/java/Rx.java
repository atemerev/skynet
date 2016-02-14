import rx.Observable;
import rx.Scheduler;
import rx.Single;
import rx.schedulers.Schedulers;

import java.util.stream.IntStream;
import java.util.stream.Stream;

public class Rx {
  public Rx() {
    // Warm up to get more consistent results when timing.
    IntStream.range(0, 5).forEach(i -> {
      Stream.of(
          Schedulers.immediate(),
          Schedulers.computation(),
          Schedulers.io()
      ).forEach(s -> skynet().subscribeOn(s).toBlocking().value());
    });
  }

  public void run() {
    run("immediate", Schedulers.immediate());
    run("computation", Schedulers.computation());
    run("io", Schedulers.io());
  }

  private static void run(String name, Scheduler scheduler) {
    Skynet.time(name,
        () -> skynet().subscribeOn(scheduler)
            .toBlocking()
            .value());
  }

  private static Single<Long> skynet() {
    return skynet(0, 1000000, 10).toSingle();
  }

  private static Observable<Long> skynet(int num, int size, int div) {
    if (size == 1) {
      return Observable.just((long) num);
    }

    return Observable.range(0, div)
        .switchMap(i -> {
          int subNum = num + i * (size / div);
          return skynet(subNum, size / div, div);
        })
        .reduce((a, b) -> a + b)
        ;
  }
}
