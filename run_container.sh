#!/bin/bash

# From: https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail

vol_path=""

if [ "$1" == "-h" ]; then
	echo "Usage: run_container.sh [-h] image_name [--volume-path path]"
	exit 0
fi

if [ $# -eq 0 ]; then
	echo "Docker image name not supplied"
	exit 1
fi
image_name="$1"
shift

while test $# -gt 0; do
	case "$1" in
		--volume-path)
			shift
			vol_path=$1
			shift
			;;
	esac
done

USER_ID="$(id -u)"

HOME_DIR="/home/developer"

mount_cmd=""
if [ ! -z "$vol_path" ]; then
	mount_cmd="--mount type=bind,source=$vol_path,target=/mnt"
fi


docker_cmd="docker run --net=host -it --rm --user=$USER_ID -w $HOME_DIR $mount_cmd $image_name /bin/bash"
eval "$docker_cmd"
