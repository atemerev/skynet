'use strict'
const Promise = require('bluebird')
const div = 10

function skynetAsync(num, size, div) {
  if (size == 1) {
    return num; //Promise.resolve(num);
  }
  else {
    const tasks = new Array(div);
    const sz = size/div;
    for (let i = 0; i < div; i++) {
      const sub_num = num + i * sz;
      const task = skynetAsync(sub_num, sz, div);
      tasks[i]=task;
    }
    return Promise.all(tasks).then(sum);
  }
}

function sum(values) {
  var sum = 0;
  for (var k = 0; k < values.length; ++k) {
    sum += values[k]
  }
  return sum;
}

console.time("regular")
skynetAsync(0, 1000000, div)
.then(res => {
    console.log(res)
    console.timeEnd("regular")
    console.time("warmed-up")
    return skynetAsync(0, 1000000, div)
}).then(res => {
    console.log(res)
    console.timeEnd("warmed-up")
})
