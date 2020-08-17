#!/bin/sh

host=root@cora_z7
remotedest=/sdcard/boot

files="
build/boot.bin \
build/uEnv.txt"

if [ "$1" == "remote" ]; then
    # We're copying boot files to sdcard on the remote target.
    # Assume that its mounted at /sdcard/boot
    echo "Copying files to sdcard on remote board."
    scp $files $host:$remotedest
    echo "Syncing changes on remote."
    ssh $host "cd /sdcard/boot; sync"
else
    # Arg $1 is the local mount point.
    echo "Copying files to $1."
    test -e $1 && cp $files $1
fi
