#!/bin/sh -ex

set -a

REPOSITORY=nodejs

SUPPORTED_NODE_VERSIONS=(
	"6.0.0:5.0.0"
	"8.9.2:5.5.0"
	"9.3.0:5.6.0"
)

OS=(
	"fedora"
	"centos"
	"rhel"
)

DEFAULT_PORT=9090
DEFAULT_APP_REGISTRY="registry.centos.org/centos"
# DEFAULT_OS="rhel"
DEFAULT_OS="centos"
# DEFAULT_OS_VERSION="7.4"
DEFAULT_OS_VERSION="7"
DEFAULT_NODE_VERSION=9.3.0
DEFAULT_NPM_VERSION=5.6.0
DEFAULT_PUSH_REGISTRY=push.registry.devshift.net
DEFAULT_PULL_REGISTRY=registry.devshift.net
DEFAULT_ORGANIZATION=fabric8-hypothesis
# DEFAULT_OS_REGISTRY=registry.access.redhat.com/rhel7
DEFAULT_OS_REGISTRY=${DEFAULT_APP_REGISTRY}
BUILD_MACHINE_OS=$(echo `cat /etc/*-release | grep -i "^id=" | cut -d'=' -f 2` | tr -d '"' | tr '[:upper:]' '[:lower:]')
# Expected as ENV vars in build machines
# SUBSCRIPTION_USERNAME=""
# SUBSCRIPTION_PASSWORD=""

set +a
