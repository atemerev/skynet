package main

import "fmt"
import "time"

func skynet(c chan int, num int, size int, div int) {
	if size == 1 {
		c <- num
		return
	}

	rc := make(chan int)
	var sum int
	for i := 0; i < div; i++ {
		subNum := num + i*(size/div)
		go skynet(rc, subNum, size/div, div)
	}
	for i := 0; i < div; i++ {
		sum += <-rc
	}
	c <- sum
}

func main() {
	c := make(chan int)
	start := time.Now()
	go skynet(c, 0, 1000000, 10)
	result := <-c
	took := time.Since(start)
	fmt.Printf("Result: %d in %d ms.\n", result, took.Nanoseconds()/1e6)
}
