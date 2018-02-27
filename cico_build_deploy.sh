#!/bin/sh

set -ex

. cico_utils/setup_utils.sh
. ./constants.sh
. ./VERSION.sh

setup() {
    prep_env
    BUILD_ARGS=$( format_build_args OS_IMG_NAME=${DEFAULT_OS} OS_IMG_VERSION=${DEFAULT_OS_VERSION} OS_REGISTRY=${DEFAULT_OS_REGISTRY} SUBSCRIPTION_USERNAME=${SUBSCRIPTION_USERNAME} SUBSCRIPTION_PASS=${SUBSCRIPTION_PASSWORD} )
    build_push_images -repo "${REPOSITORY}" -build-args "${BUILD_ARGS}" -test no
}

setup
