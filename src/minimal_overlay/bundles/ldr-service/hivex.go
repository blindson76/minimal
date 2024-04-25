package main

/*
#cgo CFLAGS:-I/home/user/work/mini/src/work/tmp_rootfs/include
#cgo LDFLAGS:-L/home/user/work/mini/src/work/tmp_rootfs/lib -lparted -lhivex
#include <hivex.h>


*/
import "C"
import (
	"unsafe"
)

type Hive struct {
	file string
	hiv  *C.hive_h
	n    C.hive_node_h
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
func OpenHive(path string) *Hive {
	self := &Hive{
		file: path,
	}
	hnd, err := C.hivex_open(C.CString(path), 0)
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
