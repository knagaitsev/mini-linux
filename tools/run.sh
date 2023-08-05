#!/bin/bash

set -e

make kmod -j$(nproc)
make root/main

WORKSPACE=$(pwd)

pushd root
	pwd
	find . -print0 \
		| cpio --quiet --null -ov --format=newc \
		| gzip --quiet -9 > $WORKSPACE/build/initramfs.cpio.gz 2>/dev/null
popd


QEMU_FLAGS="-smp 8 -m 8G -M q35 "
QEMU_FLAGS+="-enable-kvm "
QEMU_FLAGS+="-global kvm-pit.lost_tick_policy=discard "
QEMU_FLAGS+="-kernel $WORKSPACE/build/arch/x86_64/boot/bzImage "
# QEMU_FLAGS+="-initrd $WORKSPACE/build/initramfs.cpio.gz "
QEMU_FLAGS+="-nographic "
# QEMU_FLAGS+="-display curses "

QEMU_FLAGS+="-netdev user,id=net0,hostfwd=tcp::22222-:22 -device virtio-net-pci,netdev=net0 "
QEMU_FLAGS+="-rtc base=localtime "
# QEMU_FLAGS+="-cdrom ubuntu-22.04.2-live-server-amd64.iso "
# QEMU_FLAGS+="-drive file=root.qcow2,format=qcow2 "
# QEMU_FLAGS+="-hda root.qcow2 "
# QEMU_FLAGS+="-hda ubuntu.img "
QEMU_FLAGS+="-hda bullseye.img "

echo $QEMU_FLAGS
qemu-system-x86_64 $QEMU_FLAGS -append "console=ttyS0 root=/dev/sda debug earlyprintk=serial slub_debug=QUZ" $@
