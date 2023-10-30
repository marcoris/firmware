#!/usr/bin/env bash

KERNEL_VERSION=6.5.3
BUSYBOX_VERSION=1.36.1

##########################################################################

KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d '.' -f 1)
CORES=-j$(nproc)
source .env
mkdir -p src
cd src
		wget https://mirrors.edge.kernel.org/pub/linux/kernel/v$KERNEL_MAJOR.x/linux-$KERNEL_VERSION.tar.xz
		tar -xf linux-$KERNEL_VERSION.tar.xz
		cd linux-$KERNEL_VERSION
			 make defconfig
			 make $CORES || exit
		cd ..

		wget https://www.busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
		tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
		cd busybox-$BUSYBOX_VERSION
				make defconfig
				sed 's/^.*CONFIG_STATIC[^_].*$/CONFIG_STATIC=y/g' -i .config
				make $CORES busybox || exit
		cd ..

cp linux-$KERNEL_VERSION/arch/x86_64/boot/bzImage ./
mkdir -p initrd
cd initrd
		mkdir -p bin dev proc sys
		cd bin
				cp ../../busybox-$BUSYBOX_VERSION/busybox ./
				for prog in $(./busybox --list); do
								ln -s /bin/busybox ./$prog
				done
				cd ..
		echo '#!/bin/sh' > init
		echo 'mount -t sysfs sysfs /sys' >> init
		echo 'mount -t proc proc /proc' >> init
		echo 'mount -t devtmpfs udev /dev' >> init
		echo 'sysctl -w kernel.printk="2 4 1 7"' >> init
		echo '/bin/sh' >> init
		echo 'poweroff -f' >> init
		chmod -R 777 .
		find . | cpio -o -H newc > ../initrd.img
		cd ..
qemu-system-x86_64 -kernel bzImage -initrd initrd.img -nographic -append 'console=ttyS0'
