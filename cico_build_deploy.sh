#!/bin/bash

set -x

. cico_utils/setup_utils.sh
. constants.sh
. VERSION.sh

setup() {
    prep_env
    build_push_images -repo "${REPOSITORY}" -app-version "${APP_VERSION}" -test false
}

setup
