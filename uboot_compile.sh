#/bin/bash

MAKE_CONFIG="make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- penguin_uboot_defconfig -j16"
MAKE_UBOOT="make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- -j16"
CLEAN_UBOOT="make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- distclean -j16"

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
