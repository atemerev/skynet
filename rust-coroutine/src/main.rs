extern crate coroutine;

use coroutine::asymmetric::Coroutine;

fn skynet(me: coroutine::asymmetric::CoroutineRef<(u64, u64)>) {
    let (my_number, remaining) = me.take_data().unwrap();

    if remaining==1 {
        me.yield_with((my_number, 0));
    } else {
        let mut coros: Vec<coroutine::asymmetric::Coroutine<(u64, u64)>> = Vec::with_capacity(10);

        for _ in 0..10 {
            coros.push(Coroutine::spawn(&skynet));
        }

        let mut res = 0u64;
        for i in 0..10 {
            let (x, _) = coros[i].resume_with((my_number + (i as u64)*remaining/10, remaining/10)).unwrap().unwrap();
            res += x;
            coros[i].resume().unwrap();
        }

        me.yield_with((res, 0));
    }
}

fn main() {
    let coro: Coroutine<(u64, u64)> = Coroutine::spawn(&skynet);
    let (num, _) = coro.resume_with((0,1000000)).unwrap().unwrap();

    println!("{}", num);

    coro.resume().unwrap();
}
