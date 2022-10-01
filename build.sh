#/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DL="$SCRIPT_DIR/buildroot-2022.02/dl"
CONFIG="$SCRIPT_DIR/buildroot-2022.02/configs/panda_defconfig"

MAKE_CONFIG="sudo make panda_defconfig"
MAKE_MENUCONFIG="sudo make menuconfig"
MAKE_BUSYBOX="sudo make busybox-menuconfig -j16"
MAKE_BUILDROOT="sudo make -j16"
CLEAN_BUILDROOT="sudo make clean -j16"

if [ ! -d "$DL" ]
then
	ln -rs dl buildroot-2022.02/dl
fi

if [ ! -f "$CONFIG" ]
then
	ln -rs panda_defconfig buildroot-2022.02/configs/panda_defconfig
fi


if [ $1 = "-h" ]
then
	echo "-m make buildroot"
	echo "-c clean buildroot"
	
elif [ $1 = "-c" ]
then
	cd $SCRIPT_DIR/buildroot-2022.02
	$CLEAN_BUILDROOT

elif [ $1 = "-m" ]
then
	cd $SCRIPT_DIR/buildroot-2022.02
	$MAKE_CONFIG && $MAKE_MENUCONFIG && cp .config $SCRIPT_DIR/panda_defconfig
	$MAKE_BUSYBOX
	$MAKE_BUILDROOT

else
	echo "Please enter -h for help!"

fi
