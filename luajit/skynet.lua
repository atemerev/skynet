local yield = coroutine.yield
local resume = coroutine.resume
local co = coroutine.create

function skynet (num, size)
  if size == 1 then
    return yield(num)
  end

  size = size / 10
  local acc = 0

  for i = 0, 9 do
    local _, result = resume(co(skynet), num + i * size, size)
    acc = acc + result
  end

  return yield(acc)
end

local _, result = resume(co(skynet), 0, 1000000)

print(result)
