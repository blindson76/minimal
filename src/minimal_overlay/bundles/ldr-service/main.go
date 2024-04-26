package main

/*
#cgo CFLAGS:-I/home/user/work/mini/src/work/tmp_rootfs/include
#cgo LDFLAGS:-L/home/user/work/mini/src/work/tmp_rootfs/lib -lparted -lhivex -lblkid
#include <parted/parted.h>
#include <hivex.h>
#include <blkid/blkid.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/sysmacros.h>
PedDevice* get_device(char* dev){
	ped_device_probe_all();
	ped_device_get(dev);
}

void test_stat(const char* file){
	printf("%s\r\n", file);
	struct stat pStat;
	int res = fstatat(-100, file, &pStat, 0);
	printf("res:%d:%d\r\n", major(pStat.st_rdev), minor(pStat.st_rdev));

}
*/
import "C"
import (
	"encoding/binary"
	"encoding/hex"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

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

func GetDiskFromPart(part string) string {
	var stat C.struct_stat
	rp := C.fstatat(-100, C.CString(part), &stat, 0)
	if rp != 0 {
		panic("Not found")
	}
	plink := fmt.Sprintf("/sys/dev/block/%d:%d", (stat.st_rdev&0xff00)>>8, 0)
	res, _ := os.Readlink(plink)
	paths := strings.Split(res, "/")
	return "/dev/" + paths[len(paths)-1]
}

func main() {

	flag.StringVar(&bcdFlag, "b", "/media/sf_work/bcd_disk", "bcd store")
	flag.StringVar(&devFlag, "s", "/dev/nbd1", "os partition")

	rp := GetDiskFromPart("/dev/nbd0p1")
	fmt.Println(rp)
	//C.test_stat()

	if 2 > 1 {
		return
	}
	fmt.Println(filepath.EvalSymlinks("/dev/nbd1p1"))
	res := C.blkid_new_probe_from_filename(C.CString("/dev/nbd1"))
	fmt.Println(res)
	duid := GetDevice("/dev/nbd1").GetDisk().UUID()
	h := OpenHive("/media/sf_work/bcd_disk").GetChild("Objects")
	for _, c := range h.Childs() {
		for _, filed := range c.GetChild("Elements").Childs() {
			if filed.Name() == "11000001" {
				fieldVal := filed.Val("Element")
				fmt.Println(hex.EncodeToString(fieldVal))
				copy(fieldVal[56:], EncodeUUID(duid))
				fmt.Println(hex.EncodeToString(fieldVal))
			}
		}
	}
}
func main_disk() {
	dev := C.get_device(C.CString("/dev/nbd0"))
	if dev == nil {
		panic("disk not found")
	}
	gptType := C.ped_disk_type_get(C.CString("gpt"))
	if gptType == nil {
		panic("No partition type found")
	}
	pDisk := C.ped_disk_new_fresh(dev, gptType)
	if pDisk == nil {
		panic("Couldn't create partition table")
	}
	create_part(pDisk, "fat32", 512*1024*1024)
	res := C.ped_disk_commit(pDisk)
	fmt.Println("Result:", res)
	/*
		pDisk := C.ped_disk_new(dev)
		if pDisk == nil {
			fmt.Println("no partition table found. Creating...")

			gptType := C.ped_disk_type_get(C.CString("gpt"))
			if gptType == nil {
				panic("No partition type found")
			}
			pDisk = C.ped_disk_new_fresh(dev, gptType)
			if pDisk == nil {
				panic("Couldn't create partition table")
			}
			res := C.ped_disk_commit(pDisk)
			fmt.Println("Result:", res)
		} else {
			pDiskType := C.ped_disk_probe(dev)
			fmt.Println("Found partition table", C.GoString(pDiskType.name))
			var pPart *C.PedPartition = nil
			for {
				pPart := C.ped_disk_next_partition(pDisk, pPart)
				fmt.Println("Part:", pPart)
				break
			}
	*/
}
