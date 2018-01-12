#!/bin/bash -ex

. constants.sh
. cico_utils/setup_env.sh

load_jenkins_vars() {
    if [ -e "jenkins-env" ]; then
        cat jenkins-env \
          | grep -E "(DEVSHIFT_TAG_LEN|DEVSHIFT_USERNAME|DEVSHIFT_PASSWORD|JENKINS_URL|GIT_BRANCH|GIT_COMMIT|BUILD_NUMBER|ghprbSourceBranch|ghprbActualCommit|BUILD_URL|ghprbPullId)=" \
          | sed 's/^/export /g' \
          > ~/.jenkins-env
        source ~/.jenkins-env
    fi
}

install_docker() {
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y install docker-ce
    systemctl start docker
}

prep_env() {
    prep_base
    install_node 9.3.0 5.6.0
    install_docker
    load_jenkins_vars
    docker_login
    install_app
}

docker_login(){
    push_registry=$(make get-registry)
    # login first
    if [ -n "${DEVSHIFT_USERNAME}" -a -n "${DEVSHIFT_PASSWORD}" ]; then
        docker login -u ${DEVSHIFT_USERNAME} -p ${DEVSHIFT_PASSWORD} ${push_registry}
    else
        echo "Could not login, missing credentials for the registry"
        exit 1
    fi
}

format_build_args() {
    # format_build_args NODE_VERSION=9.3.0 NPM_VERSION=5.6.0 PORT=9999
    local formatted_build_args
    local BUILD_ARG_NAME
    local BUILD_ARG_VALUE
    local format_build_arg
    for build_arg in $@
    do
        IFS='=' read BUILD_ARG_NAME BUILD_ARG_VALUE <<< $build_arg
        format_build_arg=$(make BUILD_ARG_NAME=${BUILD_ARG_NAME} BUILD_ARG_VALUE=${BUILD_ARG_VALUE} get-formatted-build-arg)
        formatted_build_args="${formatted_build_args} ${format_build_arg}"
    done
    echo $formatted_build_args | xargs
}

build_image(){
    # build_image -repo nodejs -tag "9.3.0_npm_5.6.0" -build-args "--build-arg NODE_VERSION=9.3.2 --build-arg NPM_VERSION=5.6.0 --build-arg PORT=9999" -docker-file Dockerfile
    local REPOSITORY
    local TAG=$(make get-image-tag)
    local BUILD_ARGS
    local DOCKERFILE="Dockerfile"
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -build-args)
        BUILD_ARGS="$2"
        shift # past argument
        shift # past value
        ;;
        -repo)
        REPOSITORY="$2"
        shift # past argument
        shift # past value
        ;;
        -tag)
        TAG="$2"
        shift # past argument
        shift # past value
        ;;
        -docker-file)
        DOCKERFILE="$2"
        shift
        shift
        ;;
        *)
        shift
        ;;
    esac
    done
    make REPOSITORY=$REPOSITORY TAG=$TAG BUILD_ARGS="${BUILD_ARGS}" DOCKERFILE=$DOCKERFILE docker-build
}

test_image() {
    # test_image -repo nodejs-tests -tag "9.3.0_npm_5.6.0" -build-args "--build-arg NODE_VERSION=9.3.2 --build-arg NPM_VERSION=5.6.0 --build-arg PORT=9999"
    local REPOSITORY
    local TAG=$(make get-image-tag)
    local BUILD_ARGS
    local DOCKERFILE="Dockerfile"
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -build-args)
        BUILD_ARGS="$2"
        shift # past argument
        shift # past value
        ;;
        -repo)
        REPOSITORY="$2"
        shift # past argument
        shift # past value
        ;;
        -tag)
        TAG="$2"
        shift # past argument
        shift # past value
        ;;
        -docker-file)
        DOCKERFILE="$2"
        shift
        shift
        ;;
        *)
        shift
        ;;
    esac
    done
    REPOSITORY="${REPOSITORY}-tests"
    Dockerfile="${DOCKERFILE}.tests"
    make REPOSITORY=$REPOSITORY TAG=$TAG BUILD_ARGS="${BUILD_ARGS}" DOCKERFILE=$DOCKERFILE docker-build
}

tag_push() {
    # tag_push nodejs 9.3.0_npm_5.6.0 9.3.0_npm_5.6.0
    local REPOSITORY=$1
    local S_TAG=$2
    local T_TAG=$3
    make REPOSITORY=${REPOSITORY} S_TAG=${S_TAG} T_TAG=${T_TAG} docker-tag
    make REPOSITORY=${REPOSITORY} TAG=${T_TAG} docker-push
    if [ $? -eq 0 ]; then
         echo "CICO: Image ${target} pushed, ready to update deployed app"
    else
        echo "ERROR OCCURED WHILE PUSHING THE IMAGE"
    fi
}

build_push_images() {
    # build_push_images -repo nodejs -build-args "--build-arg PORT=9999" -app-version 1 -test false
    local BUILD_ARGS
    local REPOSITORY
    local DOCKERFILE=Dockerfile
    local APP_VERSION
    local build_args
    local tag
    local short_commit_hash=$(make get-short-commit-hash)
    local IS_TEST
    local last_succesful_node_version
    local last_succesful_npm_version
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -build-args)
        BUILD_ARGS="$2" # To hold anything other than node_version and npm_version
        shift # past argument
        shift # past value
        ;;
        -repo)
        REPOSITORY="$2"
        shift # past argument
        shift # past value
        ;;
        -docker-file)
        DOCKERFILE="$2"
        shift
        shift
        ;;
        -app-version)
        APP_VERSION="$2"
        shift
        shift
        ;;
        -test)
        IS_TEST="$2"
        shift
        shift
        ;;
        *)
        shift
        ;;
    esac
    done
    for version in "${SUPPORTED_NODE_VERSIONS[@]}" ; do
        build_args=""
        IFS=: read node_version npm_version <<< $version
        tag=$(make APP_VERSION=${APP_VERSION} NODE_VERSION=${node_version} NPM_VERSION=${npm_version} get-image-tag)
        build_args=$( format_build_args NODE_VERSION=${node_version} NPM_VERSION=${npm_version} )
        build_args="${BUILD_ARGS} ${build_args}"
        # If testing enabled, build image only if tests pass
        if [ "$IS_TEST" == "yes" ]; then
            test_image -repo "${REPOSITORY}" -tag "${tag}" -build-args "${build_args}"
            if [ $? -eq 0 ]; then
                last_succesful_node_version=${node_version}
                last_succesful_npm_version=${npm_version}
            fi
        fi
        if [ $? -eq 0 ]; then
            build_image -repo "${REPOSITORY}" -tag "${tag}" -build-args "${build_args}" -docker-file ${DOCKERFILE}
            tag_push ${REPOSITORY} ${tag} ${tag}
            if [ $? -eq 0 ] && [ "$IS_TEST" != "yes" ]; then
                last_succesful_node_version=${node_version}
                last_succesful_npm_version=${npm_version}
            fi
        else
            echo "${REPOSITORY} Tests failed for tag ${tAG}"
        fi
    done
    tag=$(make APP_VERSION=${APP_VERSION} NODE_VERSION=${last_succesful_node_version} NPM_VERSION=${last_succesful_npm_version} get-image-tag)
    tag_push ${REPOSITORY} ${tag} $(make get-image-tag) # Tagging last succssfully built image as latest
    tag_push ${REPOSITORY} ${tag} ${short_commit_hash} #Tagging with short commit hash - requirement for SD team to deploy to opensift cluster
    if [ $? -eq 0 ]
    then
        echo "${REPOSITORY} Builds passed \\o/"
    else
        echo "${REPOSITORY} Builds failing."
        exit 1
    fi

}
