#!/bin/sh

set -x

. cico_utils/setup_utils.sh
. ./constants.sh
. ./VERSION.sh

setup() {
    prep_env
    BUILD_ARGS=$( format_build_args OS_IMG_NAME=${DEFAULT_OS} OS_IMG_VERSION=${DEFAULT_OS_VERSION} APP_REGISTRY=${DEFAULT_APP_REGISTRY})
    build_push_images -repo "${REPOSITORY}" -build-args "${BUILD_ARGS}" -test no
}

setup
