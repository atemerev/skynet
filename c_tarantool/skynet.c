#include <tarantool/module.h>
#include "tarantool/src/ipc.h"
#include "tarantool/src/lua/clock.h"

int skynet(va_list ap) {
    struct ipc_channel *c = va_arg(ap, struct ipc_channel *);
    int num = va_arg(ap, int);
    int size = va_arg(ap, int);
    int div = va_arg(ap, int);
    
    int64_t *sum = malloc(sizeof(int64_t));
    
    if (size == 1) {
        *sum = num;   
    } else {
        struct ipc_channel *rc = ipc_channel_new(div);
        *sum = 0;
        for(int64_t i = 0; i < div; i++) {
            int64_t sub_num = num + i * (size / div);
                        
            struct fiber *skynet_fiber = fiber_new("skynet", skynet);
            fiber_start(skynet_fiber, rc, sub_num, size / div, div);            
        }
        
        // fiber_sleep(1); 
    
        for(int64_t i = 0; i < div; i++) {
            int64_t *temp;
            ipc_channel_get(rc, &temp);
            *sum += *temp;
            free(temp);
        }
        ipc_channel_delete(rc);
    }
    
    ipc_channel_put(c, sum);
    return 0;
}

int main () {
    struct ipc_channel *c = ipc_channel_new(1);
    
    uint64_t start = clock_realtime64();
    
    struct fiber *skynet_fiber = fiber_new("skynet", skynet);
	fiber_start(skynet_fiber, c, 0, 1000000, 10);
        
    int64_t *result;
    ipc_channel_get(c, &result);
    
    uint64_t time = clock_realtime64() - start;
    printf("Result: %lld in %lld ms.\n", *result, time / 1000000);
    free(result);
    ipc_channel_delete(c);
    return 0;
}
