package main

import (
	"fmt"
	"net"
	"time"
)

func main() {
	fmt.Println("👋 Hello World.")
	conn, err := net.Dial("udp", "10.10.11.1:1234")
	if err != nil {
		fmt.Printf("Some error %v", err)
		return
	}
	for {
		fmt.Fprintf(conn, "Hi UDP Server, How are you doing?")
		time.Sleep(time.Second * 2)
	}
	conn.Close()
}
