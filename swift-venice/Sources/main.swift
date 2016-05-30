import System
import Venice

func skynet(channel: Channel<Int>, num: Int, size: Int, div: Int) {
    if size == 1 {
        return channel.send(num)
    }

    let rc = Channel<Int>(bufferSize: div)
    var sum = 0

    for i in 0 ..< div {
        let subNum = num + i * (size / div)
        yield
        co(skynet(rc, num: subNum, size: size / div, div: div))
    }

    for _ in 0 ..< div {
        sum += rc.receive()!
    }

    rc.close()
    channel.send(sum)
}

let channel = Channel<Int>()

let start = now
co(skynet(channel, num: 0, size: 1000000, div: 10))
let result = channel.receive()!
let took = now - start
print("Result: \(result) in \(took) ms\n")
