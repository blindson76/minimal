#!/bin/sh

echo configuring uesr env $$
export PATH=$PATH:/nfs/nanox
export Deneme=123
# LD_LIBRARY_PATH=/nfs/nanox/lib /nfs/nanox/nano-X & sleep 1 &  /nfs/nanox/demo-nuklear-demo
demo-nuklear-demo
exec /bin/sh
cd /nfs
