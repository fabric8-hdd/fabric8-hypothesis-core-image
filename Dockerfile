FROM registry.centos.org/centos/centos:7

LABEL maintainer="Anmol Babu <anmolbudugutta@gmail.com>"

# User defined build variables
ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-9.3.0}

ARG NPM_VERSION
ENV NPM_VERSION ${NPM_VERSION:-5.6.0}

# Set dependencies
RUN yum clean all && yum -y install wget

# Install nodejs
RUN wget --no-check-certificate https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz \
    && tar --strip-components 1 -xzf node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local/ \
    && npm install "npm@v${NPM_VERSION}" -g
