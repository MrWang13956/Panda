#/bin/bash

#获取当前脚本的绝对路径
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BUILD_PATH="$OUTPUT_PATH/${SCRIPT_DIR##*/}"

MAKE_CONFIG="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE penguin_uboot_defconfig O=$BUILD_PATH"
MAKE_UBOOT="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE O=$BUILD_PATH -j16"
CLEAN_UBOOT="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE O=$BUILD_PATH distclean -j16"

if [ $1 = "-h" ]
then
	echo "-m make uboot"
	echo "-c clean uboot"

elif [ $1 = "-c" ]
then
	$CLEAN_UBOOT

elif [ $1 = "-m" ]
then
	$MAKE_CONFIG && $MAKE_UBOOT

else
	echo "Please enter -h for help!"
fi
