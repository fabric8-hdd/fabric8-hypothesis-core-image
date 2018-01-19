#!/bin/bash

. cico_utils/setup_utils.sh
. constants.sh

run_tests(){
    local APP_PORT
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -port)
        APP_PORT="$2" # To hold anything other than node_version and npm_version
        shift # past argument
        shift # past value
        ;;
    esac
    done
    # run_tests nodejs
    prep_env
    local REPOSITORY=$1

    TEMP=$(date +%s)

    if [ -z $TAG ]
    then
    TAG=$TEMP
    fi

    set -ex

    BUILD_ARGS=$( format_build_args CACHEBUST=${TEMP} PORT=${APP_PORT} )
    build_push_images -repo "${REPOSITORY}-tests" -app-version 1 -test false -docker-file Dockerfile.tests -build-args "${BUILD_ARGS}"
    docker_infra_test
}

#Running the Docker infra test

docker_infra_test(){
    dock_ver="$(docker info|grep "Server Version"|cut -d':' -f 2 | xargs)"
    required_dock_ver="17.08.0"
    if [ $(expr ${dock_ver} \>= ${required_dock_ver}) == 1 ]; then
        echo "Required version of docker is installed"
    else
        echo "Docker version test failed"
    fi
}

#Running the OC infra test

oc_infra_test(){
    oc_ver="$(oc version | grep -i 'oc' | cut -d' ' -f 2)"
    required_oc_ver="3.6.0+c4dd4cf"
    if [ $(expr ${oc_ver//v} \== ${required_oc_ver}) == 1 ]; then
        echo "Required version of openshift is installed"
    else
        echo "Openshift version test failed"
    fi
}
