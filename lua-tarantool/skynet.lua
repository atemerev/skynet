#!/usr/local/bin/tarantool

fiber = require('fiber')

function skynet(c, num, size, div)
    
    if size == 1 then 
        c:put(num)
        return
    end
    
    local rc = fiber.channel(div)
    local sum = 0
    
    for i=0,(div-1) do 
        local sub_num = num + i * (size / div)
        fiber.create(skynet, rc, sub_num, size / div, div)
    end
    
    for i=0,(div-1) do
        sum = sum + rc:get(1)
    end
    
    rc:close()
    c:put(sum)
end

local start = os.clock()

local channel = fiber.channel(0)
fiber.create(skynet, channel, 0, 1000000, 10)
result = channel:get(1)

local took = (os.clock() - start) * 1000
print('Result: ' .. result .. ' in ' .. took .. ' ms.')

os.exit(0)