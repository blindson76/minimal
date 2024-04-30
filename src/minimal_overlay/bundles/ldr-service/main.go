package main

import "C"
import (
	"encoding/binary"
	"flag"
	"fmt"
	"os"
)

func EncodeUUID(data []byte) []byte {
	ndata := make([]byte, 16)
	copy(ndata, data)
	binary.LittleEndian.PutUint32(ndata[0:], binary.BigEndian.Uint32(data[0:]))
	binary.LittleEndian.PutUint16(ndata[4:], binary.BigEndian.Uint16(data[4:]))
	binary.LittleEndian.PutUint16(ndata[6:], binary.BigEndian.Uint16(data[6:]))
	return ndata
}

var (
	bcdFlag string
	devFlag string
)

func main() {

	flag.StringVar(&bcdFlag, "b", "", "bcd store")
	flag.StringVar(&devFlag, "s", "", "os partition")
	flag.Parse()
	if bcdFlag == "" || devFlag == "" {
		panic("arguments required ")
	}
	fmt.Println("bcd:", bcdFlag)

	if 2 > 1 {
		//return
	}
	err := BCDFix(bcdFlag, devFlag)
	fmt.Println(err)
	os.Exit(1)
}
