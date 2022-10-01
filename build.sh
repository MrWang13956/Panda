#/bin/bash


SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ $1 = "-h" ]
then
	echo "-m make"
	echo "-c clean"
	
elif [ $1 = "-c" ]
then
	echo "clean all"
	rm -rf $OUTPUT_PATH/*

elif [ $1 = "-m" ]
then
	echo "compile all"
	if [ ! -d "$OUTPUT_PATH" ]
	then
		mkdir $OUTPUT_PATH
	fi
	cd $LOCAL_UBOOT && ./build.sh -m
	cd $LOCAL_LINUX && ./build.sh -m
	cd $SCRIPT_DIR && ./pack_tf_img.sh all

else
	echo "Please enter -h for help!"

fi
