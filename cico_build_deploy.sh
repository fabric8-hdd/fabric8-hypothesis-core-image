#!/bin/bash

set -x

. utils/setup_utils.sh
. constants.sh

setup() {
    prep_env
    build_push_images -repo "${REPOSITORY}" -app-version 1 -test false
}

setup
