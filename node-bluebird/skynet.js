var Promise = require('bluebird')

function skynetAsync(num, size, div) {
  if (size == 1) {
    return num; //Promise.resolve(num);
  }
  else {
    var tasks = [];
    for (var i = 0; i < div; i++) {
      var sub_num = num + i * (size / div);
      var task = skynetAsync(sub_num, size / div, div);
      tasks.push(task);
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
skynetAsync(0, 1000000, 10)
.then(res => {
    console.log(res)
    console.timeEnd("regular")
    console.time("warmed-up")
    return skynetAsync(0, 1000000, 10)
}).then(res => {
    console.log(res)
    console.timeEnd("warmed-up")
})
