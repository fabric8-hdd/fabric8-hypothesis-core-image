ARG APP_REGISTRY="registry.centos.org/centos"
ARG OS_IMG_NAME="centos"
ARG OS_IMG_VERSION="7"

FROM ${APP_REGISTRY}/${OS_IMG_NAME}:${OS_IMG_VERSION}

LABEL maintainer="Anmol Babu <anmolbudugutta@gmail.com>"

# User defined build variables
ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-9.3.0}

ARG NPM_VERSION
ENV NPM_VERSION ${NPM_VERSION:-5.6.0}

# Add the os specific default arguments
ARG OS_IMG_NAME=centos
ARG OS_IMG_VERSION=7

# Add the os_wrapper script
ADD os_wrapper.sh ./os_wrapper.sh
ADD setup_env ./setup_env

# Running the OS wrapper script
RUN ./os_wrapper.sh -os ${OS_IMG_NAME} -os-version ${OS_IMG_VERSION}