import java.util.*;
import java.util.concurrent.*;
import java.util.stream.*;

public class Skynet extends RecursiveAction {
    private long num;
    private int size;
    private int div;

    private long result;

    Skynet(long num, int size, int div) {
        this.num = num;
        this.size = size;
        this.div = div;
    }

    @Override
    public void compute() {
        if (size == 1) {
            result = num;
        } else {
            int newDiv = size / div;
            List<Skynet> subtasks = new ArrayList<>(div);

            for (long idx = 0; idx < div; idx++) {
                long subNum = num + (idx * newDiv);
                subtasks.add(new Skynet(subNum, newDiv, div));
            }

            invokeAll(subtasks);

            result = subtasks.stream().mapToLong(Skynet::result).sum();
        }
    }

    public long result() {
        return result;
    }

    public static void main(String[] args) throws InterruptedException, ExecutionException {
        int limit = 1_000_000;
        ForkJoinPool pool = new ForkJoinPool();

        for (int i = 0; i < 10; i++) {
            long start = System.nanoTime();
            Skynet sky = new Skynet(0, limit, 10);
            pool.invoke(sky);
            System.out.println("Result: " + sky.result());
            long end = System.nanoTime();
            System.out.printf("Took: %.2fms%n", (end - start) / 1000000.0);
        }
    }
}
