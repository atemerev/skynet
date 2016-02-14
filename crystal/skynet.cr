def skynet(c, num, size, div)
  if size == 1
    c.send num
  else
    rc = Channel(Int64).new
    sum = 0_i64
    div.times do |i|
      sub_num = num + i*(size/div)
      spawn skynet(rc, sub_num, size/div, div)
    end
    div.times do
      sum += rc.receive
    end
    c.send sum
  end
end

c = Channel(Int64).new
start_time = Time.now
spawn skynet(c, 0_i64, 1_000_000, 10)
result = c.receive
end_time = Time.now
puts "Result: #{result} in #{(end_time - start_time).total_milliseconds.to_i}ms."
