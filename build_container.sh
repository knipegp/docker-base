#!/bin/bash

# From: https://sipb.mit.edu/doc/safe-shell/
set -euf -o pipefail

if [ "$1" == "-h" ]; then
	echo "Usage: build_container.sh [-h] image_name dockerfile_path [docker build flags]"
	exit 0
fi

if [ -z "$1" ]; then
	echo "Please supply image name"
	exit 1
fi
image_name="$1"
shift

if [ ! -f "$1" ]; then
	echo "Specified Dockerfile path does not exist"
	exit 1
fi
dockerfile="$1"
context="$(dirname "$dockerfile")"
shift

docker build -f "$dockerfile" "$context" -t "$image_name" \
    --build-arg USER_ID="$(id -u)" --build-arg GROUP_ID="$(id -g)" "$@"
