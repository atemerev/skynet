import asyncio

LEVELS = 6
SONS = 10


async def coroutine(level=0, index=0):
    #print("{} level {} index {}".format("  "*level, level, index))
    if level < LEVELS:
        # spawn sons
        sons = [coroutine(level=level+1, index=index*SONS + x) for x in range(0, SONS)]
        sum_ = 0
        for f in asyncio.as_completed(sons):
            got = await f
            sum_ += got
        return sum_
    else:
        # last level sons return their own index
        return index

async def run_and_print():
    got = await coroutine(level=0, index=0)
    print(got)
    assert got == 499999500000

def main():
    loop = asyncio.get_event_loop()
    loop.run_until_complete(run_and_print())

if __name__ == "__main__":
    main()
