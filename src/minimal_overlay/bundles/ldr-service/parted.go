package main

/*
#cgo CFLAGS:-I/home/user/work/mini/src/work/tmp_rootfs/include
#cgo LDFLAGS:-L /home/user/work/mini/src/work/tmp_rootfs/lib -lparted
#include <parted/parted.h>
PedDevice* getDevice(char* dev){
	ped_device_probe_all();
	ped_device_get(dev);
}

*/
import "C"
import (
	"fmt"
	"unsafe"
)

type PedDisk struct {
	pDisk *C.PedDisk
}
type PedDevice struct {
	pDev *C.PedDevice
}

func (p *PedDevice) GetDisk() *PedDisk {
	pDisk := C.ped_disk_new(p.pDev)
	if pDisk == nil {
		return nil
	}
	return &PedDisk{
		pDisk: pDisk,
	}
}
func (d *PedDisk) UUID() []byte {
	uid := C.ped_disk_get_uuid(d.pDisk)
	if uid == nil {
		return nil
	}
	data := C.GoBytes(unsafe.Pointer(uid), 16)
	return data
}
func GetDevice(dev string) *PedDevice {
	pDev := C.ped_device_get(C.CString(dev))
	return &PedDevice{
		pDev: pDev,
	}
}
func Devices() []string {
	C.ped_device_probe_all()
	var pDev *C.PedDevice = nil
	var devs []*C.PedDevice
	for i := 0; i < 5; i++ {
		next, err := C.ped_device_get_next(pDev)
		if err != nil {
			fmt.Println(err)
			break
		}
		if next != nil {
			fmt.Println(i, next)
			devs = append(devs, next)
			pDev = next
		}
	}
	fmt.Println(devs)
	return nil
}
