package kilim.examples;

import kilim.Mailbox;
import kilim.Pausable;
import kilim.Task;

/** descend a tree of actors, summing the ordinals */
public class  Skynet extends Task {
    int num, size, div;
    Mailbox<Long> mb;

    public Skynet(int num, int size, int div,Mailbox mb) {
        this.num = num;
        this.size = size;
        this.div = div;
        this.mb = mb;
    }
    
    public void execute() throws Pausable{
        if ( size == 1 ) mb.put(0L+num);
        else {
            Mailbox<Long> summer = new Mailbox<Long>();
            for (int i = 0; i < div; i++) {
                int sub_num = num + i * (size / div);
                new Skynet( sub_num, size / div, div, summer ).start();
            }
            long sum = 0;
            for (int i = 0; i < div; i++)
                sum += summer.get();
            mb.put(sum);
        }
    }
    
    
    public static void main(String[] args) throws Exception {
        Mailbox<Long> summer = new Mailbox<Long>();
        for (int ii = 0; ii < 10; ii++) {
            long t0 = System.nanoTime();
            new Skynet(0, 1000000, 10, summer).start();
            System.out.format("%d, %d\n",summer.getb(),System.nanoTime()-t0);
        }
        System.exit(0);
    }
}
