#!/bin/sh -ex

REPOSITORY=nodejs

SUPPORTED_NODE_VERSIONS=(
	"6.0.0:5.0.0"
	"8.9.2:5.5.0"
	"9.3.0:5.6.0"
)

OS=(
	"fedora"
	"centos"
	"unix"
)

DEFAULT_PORT=9090
DEFAULT_APP_REGISTRY="registry.centos.org"
DEFAULT_OS="centos"
DEFAULT_OS_VERSION="7"
DEFAULT_NODE_VERSION=9.3.0
DEFAULT_NPM_VERSION=5.6.0

