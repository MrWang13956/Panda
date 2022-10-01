#!/bin/bash

#获取当前脚本的绝对路径
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export PATH=$PATH:$SCRIPT_DIR/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi/bin
export PANDA_CROSS_COMPILE="arm-linux-gnueabi-"
export OUTPUT_PATH="$SCRIPT_DIR/../output"
export LOCAL_UBOOT="$SCRIPT_DIR/../uboot"
export LOCAL_LINUX="$SCRIPT_DIR/../linux-5.4"
export LOCAL_ROOTFS="$SCRIPT_DIR/../rootfs"
export LOCAL_APP="$SCRIPT_DIR/../app"
export LOCAL_BUILDROOT="$SCRIPT_DIR/../buildroot"

export TARGET=$OUTPUT_PATH/target
export UBOOT_FILE=u-boot-sunxi-with-spl.bin
export DTB_FILE=suniv-f1c100s-panda.dtb
export KERNEL_FILE=zImage
export ROOTFS_FILE=rootfs-tf.tar.gz
export BOOTSCR_FILE=boot.scr
