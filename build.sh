#/bin/bash

#获取当前脚本的绝对路径
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BUILD_PATH="$OUTPUT_PATH/${SCRIPT_DIR##*/}"

MAKE_CONFIG="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE penguin_defconfig O=$BUILD_PATH"
MAKE_LINUX="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE -j16 O=$BUILD_PATH"
MAKE_DTBS="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE dtbs O=$BUILD_PATH"
MAKE_MODULES="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE O=$BUILD_PATH INSTALL_MOD_PATH=$BUILD_PATH modules_install"
CLEAN_LINUX="make ARCH=arm CROSS_COMPILE=$PANDA_CROSS_COMPILE distclean O=$BUILD_PATH -j16"

if [ $1 = "-h" ]
then
	echo "-m make linux"
	echo "-c clean linux"
	
elif [ $1 = "-c" ]
then
	$CLEAN_LINUX

elif [ $1 = "-m" ]
then
	if [ $2 = "dtbs" ]
	then
		$MAKE_CONFIG && $MAKE_DTBS
	else
		$MAKE_CONFIG && $MAKE_LINUX && $MAKE_MODULES
	fi
else
	echo "Please enter -h for help!"
fi
