
import gevent


def skynet(num, size, div):
    if size == 1:
        return num
    else:
        children = []
        for i in range(div):
            factor = size / div
            sub_num = int(num + i * factor)
            children.append(gevent.spawn(skynet, sub_num, factor, div))
        return sum((c.get() for c in children))


if __name__ == "__main__":
    greenlet = gevent.spawn(skynet, 0, 1000000, 10)
    result = greenlet.get()
    print(result)
    assert result == 499999500000
