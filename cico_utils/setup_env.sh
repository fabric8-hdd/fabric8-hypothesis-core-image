prep_base() {
    yum -y update
    yum -y install yum-utils device-mapper-persistent-data lvm2 git wget
}

install_node() {
    # install_node 9.3.0 5.6.0
    local NODE_VERSION="${1}"
    local NPM_VERSION="${2}"
    wget --no-check-certificate https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz
    tar --strip-components 1 -xzf node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local/
    npm install "npm@v${NPM_VERSION}" -g
}

install_app() {
    npm install
}

relocate_sources(){
    install_app
    # Create cico_utils dir in source repo if not exists and copy setup utils from fabric8-hypothesis-core-image
    mkdir -p cico_utils
    cp -r node_modules/fabric8-hypothesis-core-image/cico_utils/* cico_utils/
    # Create cico_tests dir in source repo if not exists and copy generic tests from fabric8-hypothesis-core-image
    mkdir -p cico_tests
    cp -r node_modules/fabric8-hypothesis-core-image/cico_tests/* cico_tests/
    # copy constants.sh
    cp node_modules/fabric8-hypothesis-core-image/constants.sh .
    # copy Makefile to here
    cp node_modules/fabric8-hypothesis-core-image/Makefile .
    # copy Dockerfile.app to here
    cp node_modules/fabric8-hypothesis-core-image/Dockerfile.app Dockerfile.app
    cp node_modules/fabric8-hypothesis-core-image/Dockerfile.tests Dockerfile.tests
}

setup_env() {
    prep_base
    install_node 9.3.0 5.6.0
    relocate_sources
}