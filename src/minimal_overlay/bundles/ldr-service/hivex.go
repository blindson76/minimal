package main

/*
#cgo CFLAGS:-I/home/user/work/mini/src/work/tmp_rootfs/include
#cgo LDFLAGS:-L/home/user/work/mini/src/work/tmp_rootfs/lib -lhivex
#include <hivex.h>
*/
import "C"
import (
	"errors"
	"fmt"
	"runtime"
	"unsafe"

	"github.com/google/uuid"
)

type Hive struct {
	file string
	hiv  *C.hive_h
	n    C.hive_node_h
}
type HiveValue struct {
	hiv   *C.hive_h
	n     C.hive_node_h
	pKey  *C.char
	pVal  C.hive_value_h
	pType C.hive_type
	pSize C.size_t
}

func (h *Hive) Childs() []*Hive {
	num, err := C.hivex_node_nr_children(h.hiv, h.n)
	if err != nil {
		panic(err)
	}
	childs := make([]*Hive, num)
	pChilds := unsafe.Slice(C.hivex_node_children(h.hiv, h.n), num)
	for i, v := range pChilds {
		childs[i] = &Hive{
			hiv: h.hiv,
			n:   v,
		}
	}
	return childs
}
func (h *Hive) Value(key string) *HiveValue {
	kv, err := C.hivex_node_get_value(h.hiv, h.n, C.CString(key))
	if err != nil {
		panic(err)
	}
	var vType C.hive_type
	var vSize C.size_t
	res := C.hivex_value_type(h.hiv, kv, &vType, &vSize)
	if res != 0 {
		panic(err)
	}
	pv := &HiveValue{
		hiv:   h.hiv,
		n:     h.n,
		pVal:  kv,
		pType: vType,
		pSize: vSize,
	}
	pv.pKey = C.hivex_value_key(h.hiv, kv)
	return pv
}
func (hv *HiveValue) GetBytes() []byte {
	pval, err := C.hivex_value_value(hv.hiv, hv.pVal, &hv.pType, &hv.pSize)
	if err != nil {
		panic(err)
	}
	data := C.GoBytes(unsafe.Pointer(pval), C.int(hv.pSize))
	return data
}
func (hv *HiveValue) SetByte(value []byte) error {

	var pVal C.hive_set_value
	pinner := &runtime.Pinner{}
	cPoint := unsafe.Pointer(&value[0])
	pinner.Pin(cPoint)
	defer pinner.Unpin()
	pVal.key = hv.pKey
	pVal.value = (*C.char)(cPoint)
	pVal.len = C.size_t(len(value))
	pVal.t = hv.pType
	res := C.hivex_node_set_value(hv.hiv, hv.n, &pVal, 0)
	if res == 0 {
		return nil
	}
	return errors.New(fmt.Sprintf("Couldn't set value:%d", res))
}
func (h *Hive) Val(key string) []byte {
	kv, err := C.hivex_node_get_value(h.hiv, h.n, C.CString(key))
	if err != nil {
		panic(err)
	}
	var vType C.hive_type
	var vSize C.size_t
	pval, err := C.hivex_value_value(h.hiv, kv, &vType, &vSize)
	if err != nil {
		panic(err)
	}
	data := C.GoBytes(unsafe.Pointer(pval), C.int(vSize))
	return data
}
func (h *Hive) SetVal(key string, value []byte) error {
	var pVal C.hive_set_value
	pinner := &runtime.Pinner{}
	cPoint := unsafe.Pointer(&value[0])
	pinner.Pin(cPoint)
	defer pinner.Unpin()
	pVal.key = C.CString(key)
	pVal.value = (*C.char)(cPoint)
	pVal.len = C.size_t(len(value))
	res := C.hivex_node_set_value(h.hiv, h.n, &pVal, 0)
	if res == 0 {
		return nil
	}
	return errors.New(fmt.Sprintf("Couldn't set value of hive:%d", res))
}
func (h *Hive) ValStr(key string) string {
	kv, err := C.hivex_node_get_value(h.hiv, h.n, C.CString(key))
	if err != nil {
		panic(err)
	}
	pval, err := C.hivex_value_string(h.hiv, kv)
	if err != nil {
		panic(err)
	}
	return C.GoString(pval)
}
func (h *Hive) ValDword(key string) int {
	kv, err := C.hivex_node_get_value(h.hiv, h.n, C.CString(key))
	if err != nil {
		panic(err)
	}
	pval, err := C.hivex_value_dword(h.hiv, kv)
	if err != nil {
		panic(err)
	}
	return int(pval)
}
func (h *Hive) ValQword(key string) int64 {
	kv, err := C.hivex_node_get_value(h.hiv, h.n, C.CString(key))
	if err != nil {
		panic(err)
	}
	pval, err := C.hivex_value_qword(h.hiv, kv)
	if err != nil {
		panic(err)
	}
	return int64(pval)
}
func (h *Hive) Keys() []string {
	num, err := C.hivex_node_nr_values(h.hiv, h.n)
	if err != nil {
		panic(err)
	}
	pKv := unsafe.Slice(C.hivex_node_values(h.hiv, h.n), num)
	keys := make([]string, num)
	for i, kv := range pKv {
		key := C.GoString(C.hivex_value_key(h.hiv, kv))
		keys[i] = key
	}
	return keys
}
func (h *Hive) GetChild(key string) *Hive {
	pChild, err := C.hivex_node_get_child(h.hiv, h.n, C.CString(key))
	if err != nil {
		panic(err)
	}
	return &Hive{
		hiv: h.hiv,
		n:   pChild,
	}
}
func (h *Hive) Name() string {
	pName, err := C.hivex_node_name(h.hiv, h.n)
	if err != nil {
		panic(err)
	}
	return C.GoString(pName)
}
func (h *Hive) Commit() error {
	if C.hivex_commit(h.hiv, nil, 0) == 0 {
		return nil
	}
	return errors.New("Failed to write hive")
}
func OpenHive(path string) *Hive {
	self := &Hive{
		file: path,
	}
	hnd, err := C.hivex_open(C.CString(path), C.HIVEX_OPEN_WRITE)
	if err != nil {
		panic(err)
	}
	root, err := C.hivex_root(hnd)
	if err != nil {
		panic(err)
	}
	self.n = root
	self.hiv = hnd
	return self
}
func printUUID(data []byte) {
	uid, err := uuid.FromBytes(data)
	if err != nil {
		return
	}
	fmt.Println(uid)
}
func BCDFix(bxdStore, device string) error {

	diskName, partId := GetDiskAndPartNum(device)
	fmt.Println(diskName, partId)
	dev := GetDevice(diskName)
	if dev == nil {
		panic("Couldn' open dev")
	}
	disk := dev.GetDisk()
	part := disk.GetPartition(partId)
	diskUUID := disk.UUID()
	partUUID := part.UUID()
	h := OpenHive(bxdStore).GetChild("Objects")
	printUUID(diskUUID)
	printUUID(partUUID)
	fixed := 0
	for _, c := range h.Childs() {
		for _, field := range c.GetChild("Elements").Childs() {
			if field.Name() == "11000001" || field.Name() == "21000001" {
				kv := field.Value("Element")
				fieldVal := kv.GetBytes()
				newValue := make([]byte, len(fieldVal))
				copy(newValue, fieldVal)
				copy(newValue[32:], EncodeUUID(partUUID))
				copy(newValue[56:], EncodeUUID(diskUUID))
				kv.SetByte(newValue)
				err := field.SetVal("Element", newValue)
				if err != nil {
					panic(err)
				}
				fixed += 1

			}
		}
	}
	if fixed == 2 {
		return h.Commit()
	}
	return errors.New("Unexpected result")
}
