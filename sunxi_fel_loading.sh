#/bin/bash

# 将烧录好完整镜像的sd卡擦去uboot,并在p1分区放入当前路径下生成的boot.scr,
# 就可以使用usb加载固件了
DEBUG_PATH=$TARGET/debug

if [ ! -d $DEBUG_PATH ]
then
	mkdir $DEBUG_PATH
fi

if [ ! -e $DEBUG_PATH/zero_1k.bin ]
then
	dd if=/dev/zero of=$DEBUG_PATH/zero_1k.bin bs=1024 count=1
fi

echo "清除sd卡uboot"
echo "sudo dd if=$DEBUG_PATH/zero_1k.bin of=/dev/device bs=1024 seek=8"

(
cat << EOF
setenv bootargs console=tty1 console=ttyS1,115200 panic=5 rootwait root=/dev/mmcblk0p2 rw
bootz 0x80008000 - 0x80C00000
EOF
) > $DEBUG_PATH/boot.cmd

mkimage -C none -A arm -T script -d $DEBUG_PATH/boot.cmd $DEBUG_PATH/$BOOTSCR_FILE
rm $DEBUG_PATH/boot.cmd

echo "复制boot.scr 到tf卡 一分区"
echo "$DEBUG_PATH/$BOOTSCR_FILE"

echo "查看芯片是否进入fel模式"
sunxi-fel ver

echo "加载固件"
sunxi-fel -p uboot $TARGET/$UBOOT_FILE write 0x80008000 $TARGET/$KERNEL_FILE write 0x80C00000 $TARGET/$DTB_FILE
