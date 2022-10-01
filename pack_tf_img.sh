#/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

OUTPUT_ROOTFS=$OUTPUT_PATH/${LOCAL_ROOTFS##*/}
OUTPUT_LINUX=$OUTPUT_PATH/${LOCAL_LINUX##*/}
OUTPUT_UBOOT=$OUTPUT_PATH/${LOCAL_UBOOT##*/}

#***********img config***********
_TF_CARD=$TARGET/tf-card
_P1=$_TF_CARD/p1
_P2=$_TF_CARD/p2
_IMG_SIZE=200
_UBOOT_SIZE=1
_P1_SIZE=16
_IMG_FILE=panda_tf.dd
#********************************


function pack_rootfs()
{
	if [ -d "$OUTPUT_ROOTFS" ]
	then
		rm -rf $OUTPUT_ROOTFS
	fi

	cp -rf $LOCAL_ROOTFS $OUTPUT_PATH
	cp -rf $OUTPUT_PATH/lib/* $OUTPUT_ROOTFS/lib/
	echo "modules done~"
	tar cfvz $TARGET/$ROOTFS_FILE -C $OUTPUT_ROOTFS/ .
	echo "pack rootfs done~"
}

function output_bootscr()
{
(
cat << EOF
setenv bootargs console=tty1 console=ttyS1,115200 panic=5 rootwait root=/dev/mmcblk0p2 rw
load mmc 0:1 0x80C00000 $DTB_FILE
load mmc 0:1 0x80008000 $KERNEL_FILE
bootz 0x80008000 - 0x80C00000
EOF
) > $TARGET/boot.cmd
	mkimage -C none -A arm -T script -d $TARGET/boot.cmd $TARGET/$BOOTSCR_FILE
	rm $TARGET/boot.cmd
}

function pack_boot()
{
	cp $(find $OUTPUT_LINUX/ -name $KERNEL_FILE) $TARGET/
	cp $(find $OUTPUT_LINUX/ -name $DTB_FILE) $TARGET/
	cp $(find $OUTPUT_UBOOT/ -name $UBOOT_FILE) $TARGET/
	output_bootscr
}

function pack_img()
{
	if [ ! -d "$_TF_CARD" ]
	then
		mkdir $_TF_CARD
	fi

	if [ ! -d "$_P1" ]
	then
		mkdir $_P1
	fi

	if [ ! -d "$_P2" ]
	then
		mkdir $_P2
	fi

	if [ -e $_TF_CARD/$_IMG_FILE ]
	then
		rm $_TF_CARD/$_IMG_FILE
	fi

	dd if=/dev/zero of=$_TF_CARD/$_IMG_FILE bs=1M count=$_IMG_SIZE

	_LOOP_DEV=$(sudo losetup -f)
	if [ -z $_LOOP_DEV ]
	then echo  "can not find a loop device!"
    	exit
	fi

	sudo losetup $_LOOP_DEV $_TF_CARD/$_IMG_FILE
	if [ $? -ne 0 ]
	then echo  "dd img --> $_LOOP_DEV error!"
    	sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit

	fi
    echo  "creating partitions for tf image ..."
	
cat <<EOT |sudo  sfdisk $_TF_CARD/$_IMG_FILE
${_UBOOT_SIZE}M,${_P1_SIZE}M,c
,,L
EOT
	sleep 2
    sudo partx -u $_LOOP_DEV
    sudo mkfs.vfat ${_LOOP_DEV}p1 ||exit
    sudo mkfs.ext4 ${_LOOP_DEV}p2 ||exit
    if [ $? -ne 0 ]
    then echo  "error in creating partitions"
        sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
    fi

    echo  "writing u-boot-sunxi-with-spl to $_LOOP_DEV"
    sudo dd if=$TARGET/$UBOOT_FILE of=$_LOOP_DEV bs=1024 seek=8
    if [ $? -ne 0 ]
    then echo  "writing u-boot error!"
        sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
    fi

    sudo sync
    mkdir -p $_P1 >/dev/null 2>&1
    mkdir -p $_P2 > /dev/null 2>&1
    sudo mount ${_LOOP_DEV}p1 $_P1
    sudo mount ${_LOOP_DEV}p2 $_P2
    echo  "copy boot and rootfs files..."
    sudo rm -rf  $_P1/* && sudo rm -rf $_P2/*

	sudo cp $TARGET/$KERNEL_FILE $_P1/ &&\
	sudo cp $TARGET/$DTB_FILE $_P1/ &&\
	sudo cp $TARGET/$BOOTSCR_FILE $_P1/ &&\
	echo "p1 done~"
	sudo tar xzvf $TARGET/$ROOTFS_FILE -C $_P2/ &&\
	echo "p2 done~"

	if [ $? -ne 0 ]
	then echo  "copy files error! "
	    sudo losetup -d $_LOOP_DEV >/dev/null 2>&1
	    sudo umount ${_LOOP_DEV}p1  ${_LOOP_DEV}p2 >/dev/null 2>&1
	    exit
	fi

	sudo dd if=/dev/zero of=$_P2/root/swapfile bs=1M count=32
	sudo chmod 600 $_P2/root/swapfile

	echo "The tf card image-packing task done~"

	sudo sync
    sudo umount $_P1 $_P2  && sudo losetup -d $_LOOP_DEV
    if [ $? -ne 0 ]
    then echo  "umount or losetup -d error!!"
        exit
    fi

	echo "The $_IMG_FILE has been created successfully!"

	_ROOTFS_SIZE=`gzip -l $TARGET/$ROOTFS_FILE | sed -n '2p' | awk '{print $2}'`
	_ROOTFS_SIZE=`echo "scale=3;$_ROOTFS_SIZE/1024/1024" | bc`
	_MIN_SIZE=`echo "scale=3;$_UBOOT_SIZE+$_P1_SIZE+$_ROOTFS_SIZE/1024/1024" | bc` 
	_FREE_SIZE=`echo "$_IMG_SIZE-$_MIN_SIZE"|bc`

	echo "gen img size = $_IMG_SIZE MB"
	echo "min img size = $_MIN_SIZE MB"
	echo "free space = $_FREE_SIZE MB"
}


function all()
{
	if [ ! -d "$TARGET" ]
	then
		mkdir $TARGET
	fi

	pack_rootfs
	pack_boot
	pack_img

	echo -e "\nsudo dd if=$_TF_CARD/$_IMG_FILE of=/dev/device && sync"
}

$1
