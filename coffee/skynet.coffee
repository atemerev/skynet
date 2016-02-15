{chan, go, put, takeAsync} = require 'js-csp'

skynet = (c, num, size, div) ->
  if size is 1 then yield put c, num
  else
    rc = do chan
    sum = 0

    for i in [0..div]
      subNum = num + i * size / div
      go -> skynet rc, subNum, size / div, div

    for i in [0..div]
      sum += yield rc

    yield put c, sum

    return

c = do chan
start = new Date

go -> skynet c, 0, 1e6, 10

takeAsync c, (result) ->
  end = new Date
  console.log "Result: #{result} in #{end - start} ms.\n"
