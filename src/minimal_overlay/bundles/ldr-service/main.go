package main

/*
#cgo CFLAGS:-I/home/user/work/mini/src/work/tmp_rootfs/include
#cgo LDFLAGS:-L/home/user/work/mini/src/work/tmp_rootfs/lib -lparted -lhivex
#include <parted/parted.h>
#include <hivex.h>
PedDevice* get_device(char* dev){
	ped_device_probe_all();
	ped_device_get(dev);
}


*/
import "C"
import (
	"encoding/hex"
	"fmt"
	"strings"
	"unsafe"
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
func get_value(hiv *C.hive_h, kv C.hive_value_h) string {
	var vType C.hive_type
	var vSize C.size_t
	val := C.hivex_value_value(hiv, kv, &vType, &vSize)
	vBuff := C.GoBytes(unsafe.Pointer(&val), C.int(vSize))
	//fmt.Println("VType", vtype, vSize, val, hex.EncodeToString(vBuff))

	return hex.EncodeToString(vBuff)
}
func get_childs(hiv *C.hive_h, node C.hive_node_h, order int) {
	name := C.hivex_node_name(hiv, node)
	fmt.Println(strings.Repeat(" ", order*2), "->", C.GoString(name))
	numChild := C.hivex_node_nr_children(hiv, node)
	childs := unsafe.Slice(C.hivex_node_children(hiv, node), numChild)
	for _, v := range childs {
		get_childs(hiv, v, order+1)
	}
	keyCounts := C.hivex_node_nr_values(hiv, node)
	kvs := unsafe.Slice(C.hivex_node_values(hiv, node), keyCounts)
	for _, key := range kvs {
		keyName := C.GoString(C.hivex_value_key(hiv, key))
		value := get_value(hiv, key)
		fmt.Println(strings.Repeat(" ", order*2), keyName, ":", value)
	}
}
func main() {
	hiv, err := C.hivex_open(C.CString("./BCD"), C.HIVEX_OPEN_WRITE)
	if hiv == nil {
		panic("couldn't open hive")
	}
	root, err := C.hivex_root(hiv)
	if err != nil {
		panic("couldn't open hive")
	}
	desc := C.hivex_node_get_child(hiv, root, C.CString("Objects"))
	get_childs(hiv, desc, 0)
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
