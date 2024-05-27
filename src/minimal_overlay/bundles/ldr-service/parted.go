package main

/*
#cgo CFLAGS:-I/home/user/work/mini/src/work/tmp_rootfs/include
#cgo LDFLAGS:-L /home/user/work/mini/src/work/tmp_rootfs/lib -lparted
#include <sys/stat.h>
#include <libudev.h>
#include <parted/parted.h>
*/
import "C"
import (
	"fmt"
	"os"
	"strings"
	"unsafe"
)

type PedDisk struct {
	pDisk *C.PedDisk
}
type PedDevice struct {
	pDev *C.PedDevice
}
type PedPartition struct {
	pPart *C.PedPartition
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
func (d *PedDisk) GetPartition(partNum int) *PedPartition {
	pPart := C.ped_disk_get_partition(d.pDisk, C.int(partNum))
	if pPart == nil {
		return nil
	}
	return &PedPartition{
		pPart: pPart,
	}
}

func (p *PedPartition) UUID() []byte {
	uid := C.ped_partition_get_uuid(p.pPart)
	if uid == nil {
		return nil
	}
	data := C.GoBytes(unsafe.Pointer(uid), 16)
	return data
}
func GetDevice(dev string) *PedDevice {
	pDev := C.ped_device_get(C.CString(dev))
	if pDev == nil {
		return nil
	}
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
			//fmt.Println(i, next)
			devs = append(devs, next)
			pDev = next
		}
	}
	//fmt.Println(devs)
	return nil
}

// todo: find a better way
func GetDiskByLocation(loc string) string {
	direntry, er := os.ReadDir("/sys/class/block/")
	if er != nil {
		return ""
	}
	for _, a := range direntry {
		info, _ := os.Readlink(fmt.Sprintf("/sys/class/block/%s", a.Name()))
		if strings.Contains(info, loc) {
			ovs := strings.Split(info, "/block/")
			if !strings.Contains(ovs[len(ovs)-1], "/") {
				return ovs[len(ovs)-1]
			}
			//return ovs[len(ovs)-1]
		}
	}
	return ""
}
func GetDiskAndPartNum(part string) (string, int) {
	dev := part
	if strings.Contains(part, "/") {
		parts := strings.Split(part, "/")
		dev = parts[len(parts)-1]
	}
	devPath, err := os.Readlink("/sys/class/block/" + dev)
	if err != nil {
		panic(err)
	}
	parts := strings.Split(devPath, "/")
	parentDev := parts[len(parts)-2]
	var stat, pstat C.struct_stat
	ret := C.fstatat(0, C.CString(part), &stat, 0)
	if ret != 0 {
		panic(fmt.Sprintf("Dev: %s not found", part))
	}
	ret = C.fstatat(0, C.CString("/dev/"+parentDev), &pstat, 0)
	if ret != 0 {
		panic(fmt.Sprintf("Dev: %s not found", part))
	}
	//fmt.Println(devPath, parentDev, stat.st_rdev-pstat.st_rdev)

	return "/dev/" + parentDev, int(stat.st_rdev - pstat.st_rdev)
}

func create_part(disk *C.PedDisk, fs string, size C.longlong) *C.PedPartition {
	//C.ped_partition_new()
	pAlign := C.ped_disk_get_partition_alignment(disk)
	if pAlign == nil {
		panic("couldn't get alignment")
	}

	sectorSize := C.ped_unit_get_size(disk.dev, C.PED_UNIT_SECTOR)
	start := C.longlong(0)
	end := start + size/sectorSize
	pedFS := C.ped_file_system_type_get(C.CString(fs))
	if pedFS == nil {
		panic("Fs not found")
	}
	newPart := C.ped_partition_new(disk, C.PED_PARTITION_NORMAL, pedFS, start, end)
	if newPart == nil {
		panic("partition couldn't be created")
	}
	pedConstraint := C.ped_constraint_any(disk.dev)
	res := C.ped_disk_add_partition(disk, newPart, pedConstraint)

	fmt.Println("Unit fmt:", sectorSize, start, end, res)
	return nil
}
