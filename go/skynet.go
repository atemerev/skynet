package main

import "fmt"
import "time"

func skynet(c chan int, num int, size int, div int) {
	if size == 1 {
		c <- num
	} else {
		rc := make(chan int)
		sum := 0
		for i := 0; i < div; i++ {
			sub_num := num + i*(size/div)
			go skynet(rc, sub_num, size/div, div)
		}
		for i := 0; i < div; i++ {
			sum += <-rc
		}
		c <- sum
	}
}

func main() {
	c := make(chan int)
	start := time.Now().UnixNano() / 1000000
	go skynet(c, 0, 1000000, 10)
	result := <-c
	end := time.Now().UnixNano() / 1000000
	fmt.Printf("Result: %d in %d ms.\n", result, end-start)
}
