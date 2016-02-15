#include <libmill.h>
#include <stdio.h>

/*
 * C & libmill port of the goland skynet code.
 * 
 * Libmill (http://libmill.org/) is a library that brings golang like 
 * concurrency to C.
 * 
 * I found that while libmill's implementation is very simple the 
 * current approach to scheduling coroutines and the default stack size 
 * mean that spawning all 1111111 coroutines doesn't work, therefor
 * there are some differences between this and the original golang code.
 * 
 * Putting aside the question of whether such a benchmark represents a 
 * useful scenario I think it would be interesting to explore if the 
 * current limitations can be removed, baring in mind the limitations of 
 * the C runtime.
 * 
 * This is the first time I've done anything with libmill so the 
 * there may be faster ways to do things but I was interested in how 
 * comparible it was to golang.
 * 
 * You will find it you run the benchmark that it is slower than the 
 * golang version - mostly because of the time taken in mallocing so 
 * many large stacks.
 */

coroutine void skynet(chan c, int num, int size, int div) {
    if (size == 1) {
        chs(c, int64_t, num);
    } else {
        /* 
         * Slight change from go version which used an unbuffered 
         * channel.
         */
        chan rc = chmake(int64_t, div); 
        int64_t sum = 0;
        for(int64_t i = 0; i < div; i++) {
            int64_t sub_num = num + i * (size / div);
            /* 
             * Because of the way libmill schedules coroutines without
             * the following yield() more of the coroutines which start
             * additional coroutines will run before the ones which 
             * do not (size == 1). This would result in a lot of active 
             * coroutines each with a stack (default 256K although it 
             * can be changed to 16K without modifying libmill) and 
             * many mapped pages. Even with the yield you may find that 
             * you need to increase vm.max_map_count e.g.
             * 
             *     sudo sysctl -w vm.max_map_count=2000000
             */
            yield(); 
            go(skynet(rc, sub_num, size / div, div));
        }
        for(int64_t i = 0; i < div; i++) {
            sum += chr(rc, int64_t);
        }
        chclose(rc);
        chs(c, int64_t, sum);
    }
}

int main(int argc, char **argv) {
    chan c = chmake(int64_t, 0);
    int64_t start_ms = now();
    go(skynet(c, 0, 1000000, 10));
    int64_t result = chr(c, int64_t);
    int64_t end_ms = now();
    chclose(c);
    printf("Result: %ld in %d ms.\n", result, end_ms - start_ms);
    return 0;
}
