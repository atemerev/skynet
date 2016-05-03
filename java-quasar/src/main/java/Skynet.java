import co.paralleluniverse.fibers.*;
import java.util.concurrent.ExecutionException;

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
            long start = System.nanoTime();

            long result = new Fiber<>(() -> skynet(0, TOTAL, BRANCH)).start().get();

            long elapsed = (System.nanoTime() - start) / 1_000_000;
            System.out.println((i + 1) + ": " + result + " (" + elapsed + " ms)");
        }
    }

    static final int RUNS = 4;
    static final int BRANCH = 10;
    static final int TOTAL = 1_000_000; // >= BRANCH
}
