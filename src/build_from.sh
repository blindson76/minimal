#!/bin/bash

set -e
start=$1-0
for script in $(ls | grep '^[0-9]*_.*.sh'); do
  if [[ 10#${script:0:2} -ge $1 ]] && [[ 10#${script:0:2} -lt 11 ]]
    then
      ./$script
  fi
done
./qemu-bios.sh
