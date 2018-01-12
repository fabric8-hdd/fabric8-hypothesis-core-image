#!/bin/bash

. constants.sh
. setup_utils.sh

run_tests(){
    prep_env

    TEMP=$(date +%s)

    if [ -z $TAG ]
    then
    TAG=$TEMP
    fi

    set -ex

    build_push_images -repo "${REPOSITORY}-tests" -app-version 1 -test false -docker-file Dockerfile.tests -build-args $(make BUILD_ARG_NAME="CACHEBUST" BUILD_ARG_VALUE=${TEMP} get-formatted-build-arg)
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