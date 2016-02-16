#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Venice


func skynet(c: Channel<Int>, _ num: Int, _ size: Int, _ div: Int) {
	if size == 1 {
		c.send(num)
		return
	}

	let rc = Channel<Int>()
	var sum: Int = 0
	for i in 0 ..< div {
		let subNum = num + i*(size/div)
		co(skynet(rc, subNum, size/div, div))
	}
	for _ in 0 ..< div {
		sum += rc.receive()!
	}
    rc.close()
	c.send(sum)
}

let c = Channel<Int>()

let start = clock()
co(skynet(c, 0, 1000000, 10))
let result = c.receive()
let took = Double(clock() - start) / Double(CLOCKS_PER_SEC / 1000);
c.close()
print("Result: \(result) in \(took) ms\n")

