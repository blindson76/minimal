package main

import "C"
import (
	"encoding/binary"
	"flag"
	"fmt"
	"os"
	"os/exec"
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

	cmd := exec.Command("/usr/local/sbin/parted", "-l")
	rd, err := cmd.StdoutPipe()
	//cmd.Stderr = cmd.Stdout
	if err != nil {
		panic(err)
	}

	if err = cmd.Start(); err != nil {
		panic(err)
	}

	for {
		tmp := make([]byte, 1024)
		_, err := rd.Read(tmp)
		fmt.Print(string(tmp))
		if err != nil {
			break
		}
	}

	ddev := GetDiskByLocation("pci0000:00/0000:00:0d.0")
	fmt.Println("Found dev:", ddev)
	if 2 > 1 {
		return
	}
	flag.StringVar(&bcdFlag, "b", "", "bcd store")
	flag.StringVar(&devFlag, "s", "", "os partition")
	flag.Parse()
	if bcdFlag == "" || devFlag == "" {
		panic("arguments required ")
	}
	//fmt.Println("bcd:", bcdFlag)

	if 2 > 1 {
		//return
	}
	err = BCDFix(bcdFlag, devFlag)
	if err != nil {
		os.Exit(1)
	}
	os.Exit(0)
}
