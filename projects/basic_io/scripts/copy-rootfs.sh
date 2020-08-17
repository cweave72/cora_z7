#!/bin/sh

host=root@cora_z7
remotedest=/sdcard/rootfs

# Path to rootfs tar file.
rootfs=$1

mkdir -p temp
echo "Extracting $rootfs to temporary directory."
tar -xf $rootfs -C temp
echo "Syncing new $rootfs to remote."
rsync -av -e ssh --delete --progress temp/ $host:$remotedest
ssh $host "chown -R root:root $remotedest"
ssh $host "sync"
echo "Cleaning up."
rm -rf temp
