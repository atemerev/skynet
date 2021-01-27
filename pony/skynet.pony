use "time"

interface tag Summator
  be sum(amount: U64)

actor Skynet is Summator
  let _parent: Summator
  let _div: U64

  var _sum: U64 = 0
  var _received: U64 = 0

  new create(parent: Summator, num: U64, size: U64, div: U64) =>
    _parent = parent
    _div = div

    if size == 1 then
      parent.sum(num)
      return
    end

    var i: U64 = 0
    while i < div do
      Skynet(this, (num + (i*(size/div))), size/div, div)
      i = i + 1
    end

  be sum(amount: U64) =>
    _received = _received + 1
    _sum = _sum + amount

    if _received == _div then
      _parent.sum(_sum)
    end

actor Main is Summator
  let _env: Env
  let _start_nanos : U64

  new create(env: Env) =>
    _env = env
    _start_nanos = Time.nanos()
    let main = Skynet(this, 0, 1000_000, 10)
  
  be sum(amount: U64) =>
    let elapsed_nanos = Time.nanos() - _start_nanos
    _env.out.print("Result: " + amount.string() + " in " + (elapsed_nanos / 1000_000).string() + " ms.")
