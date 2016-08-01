import co.paralleluniverse.fibers.*;
import java.util.concurrent.*;
import java.time.*;

public class Skynet {
    static long skynet(long num, int size, int div) throws SuspendExecution, InterruptedException {
        try {
            if (size == 1)
                return num;

            Fiber<Long>[] children = new Fiber[div];
            long sum = 0L;
            for (int i = 0; i < div; i++) {
                long subNum = num + i * (size / div);
                children[i] = new Fiber<>(() -> skynet(subNum, size / div, div)).start();
            }
            for (Fiber<Long> c : children)
                sum += c.get();
            return sum;
        } catch (ExecutionException e) {
            throw (RuntimeException) e.getCause();
        }
    }

    public static void main(String[] args) throws Exception {
        for (int i = 0; i < RUNS; i++) {
            Instant start = Instant.now();

            long result = new Fiber<>(() -> skynet(0, 1_000_000, 10)).start().get();

            Duration elapsed = Duration.between(start, Instant.now());
            System.out.println((i + 1) + ": " + result + " (" + elapsed.toMillis() + " ms)");
        }
    }

    static final int RUNS = 4;
}
