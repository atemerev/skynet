# -*- coding: utf-8 -*-

'''
skynet based on tornado, both py2 and py3 are supported.
inspired by python35-asyncio.
'''

from tornado import gen
from tornado.ioloop import IOLoop


LEVELS = 6
SONS = 10


@gen.coroutine
def skynet(level=0, index=0):
    if level >= LEVELS:
        raise gen.Return(index)

    futures = [skynet(level=level+1, index=index*SONS + x)
               for x in range(0, SONS)]

    sum_ = 0
    wait_iterator = gen.WaitIterator(*futures)
    while not wait_iterator.done():
        got = yield wait_iterator.next()
        sum_ += got

    raise gen.Return(sum_)


@gen.coroutine
def main():
    got = yield skynet()
    print(got)
    assert got == 499999500000


if __name__ == '__main__':
    IOLoop.current().run_sync(main)
