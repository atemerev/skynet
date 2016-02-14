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

            for (Skynet task : subtasks) {
                result += task.result();
            }
        }
    }

    public long result() {
        return result;
    }

    public static void main(String[] args) {
        int limit = 1_000_000;
        ForkJoinPool pool = new ForkJoinPool();

        for (int i = 0; i < 25; i++) {
            long start = System.nanoTime();
            Skynet sky = new Skynet(0, limit, 10);
            pool.invoke(sky);
            long end = System.nanoTime();
            System.out.println("Result: " + sky.result());
            System.out.printf("Took: %.2fms%n", (end - start) / 1000000.0);
        }
    }
}
