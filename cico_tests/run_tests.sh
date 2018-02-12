#!/bin/sh

. cico_utils/setup_utils.sh
. ./constants.sh

run_tests(){
    local APP_PORT
    local APP_NAME
    local DOCKERFILE=Dockerfile.tests
    while [[ $# -gt 0 ]]
    do
    key="$1"
    case $key in
        -app-version)
        APP_VERSION="$2"
        shift
        shift
        ;;
        -app-port)
        APP_PORT="$2" # To hold anything other than node_version and npm_version
        shift # past argument
        shift # past value
        ;;
        -app-name)
        APP_NAME="$2" # To hold anything other than node_version and npm_version
        shift # past argument
        shift # past value
        ;;
        -docker-file)
        DOCKERFILE="$2" # To hold anything other than node_version and npm_version
        shift # past argument
        shift # past value
        ;;
    esac
    done
    # run_tests nodejs
    prep_env

    TEMP=$(date +%s)

    if [ -z $TAG ]
    then
    TAG=$TEMP
    fi

    set -ex

    BUILD_ARGS=$( format_build_args CACHEBUST=${TEMP} APP_PORT=${APP_PORT} APP_NAME=${APP_NAME} )
    build_push_images -repo "${APP_NAME}-tests" -app-version ${APP_VERSION} -test no -docker-file ${DOCKERFILE} -build-args "${BUILD_ARGS}" -port "${APP_PORT}" -run-infra-tests yes
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
