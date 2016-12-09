package main

import (
	"fmt"
	"sync"
	"time"
)

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

func skynetWait(c chan int64, num int, size int, div int, wg *sync.WaitGroup) {
	if size == 1 {
		c <- int64(num)
		wg.Done()
		return
	}

	rc := make(chan int64, div)
	var inner sync.WaitGroup
	inner.Add(div)
	sum := int64(0)
	for i := 0; i < div; i++ {
		subNum := num + i*(size/div)
		go skynetWait(rc, subNum, size/div, div, &inner)
	}
	inner.Wait()
	close(rc)
	for i := range rc {
		sum += i
	}
	c <- sum
	wg.Done()
}

func skynetSync(c chan int64, num int, size int, div int) {
	if size == 1 {
		c <- int64(num)
		return
	}

	rc := make(chan int64, 10)
	var sum int64
	for i := 0; i < div; i++ {
		subNum := num + i*(size/div)
		skynetSync(rc, subNum, size/div, div)
	}
	for i := 0; i < div; i++ {
		sum += <-rc
	}
	c <- sum
}

func skynetSyncWithoutChannel(num int, size int, div int) int64 {
	if size == 1 {
		return int64(num)
	}

	sum := int64(0)
	for i := 0; i < div; i++ {
		subNum := num + i*(size/div)
		sum += skynetSyncWithoutChannel(subNum, size/div, div)
	}
	return sum
}

func main() {
	c := make(chan int)
	start := time.Now()
	go skynet(c, 0, 1000000, 10)
	result := <-c
	took := time.Since(start)
	fmt.Printf("Result: %d in %d ms.\n", result, took.Nanoseconds()/1e6)

	buffer := make(chan int64, 10)
	start = time.Now()
	skynetSync(buffer, 0, 1000000, 10)
	result2 := <-buffer
	took = time.Since(start)
	fmt.Printf("Result sync: %d in %d ms.\n", result2, took.Nanoseconds()/1e6)

	start = time.Now()
	var wg sync.WaitGroup
	wg.Add(1)
	go skynetWait(buffer, 0, 1000000, 10, &wg)
	wg.Wait()
	result2 = <-buffer
	took = time.Since(start)
	fmt.Printf("Result using wait: %d in %d ms.\n", result2, took.Nanoseconds()/1e6)

	start = time.Now()
	result2 = skynetSyncWithoutChannel(0, 1000000, 10)
	took = time.Since(start)
	fmt.Printf("Result sync without channel: %d in %d ms.\n", result2, took.Nanoseconds()/1e6)

}
