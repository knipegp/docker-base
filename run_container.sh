#!/bin/bash

set -euf -o pipefail

run_container(){
    if [ "$1" == "-h" ]; then
        echo "Usage: run_container.sh [-h] image_name [--volume-path path]"
        exit 0
    fi

    if [ $# -eq 0 ]; then
        echo "Docker image name not supplied"
        exit 1
    fi
    local vol_path=""
    local newuser=dev
    local run_args="-it --rm -w /mnt -u 0"
    local image_name="$1"
    shift
    while test $# -gt 0; do
        case "$1" in
            --volume-path)
                shift
                local vol_path=$1
                shift
                ;;
            *)
                run_args="$run_args $1"
                shift
                ;;
        esac
    done
    local groupid=""
    groupid="$(id -g)"
    local usercommand
    usercommand="\"groupadd -o -g $groupid $newuser && useradd -m -o -u $(id -u) -g $groupid $newuser && su $newuser\""
    if [ -n "$vol_path" ]; then
        run_args="$run_args --mount type=bind,source=$vol_path,target=/mnt"
    fi
    eval "docker run $run_args $image_name /bin/bash -c $usercommand"
}

run_container "$@"
