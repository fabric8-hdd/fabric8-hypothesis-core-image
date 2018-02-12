#!/bin/sh

# Install wget
yum clean all && yum -y install wget

# Install nodejs
wget --no-check-certificate https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz \
    && tar --strip-components 1 -xzf node-v${NODE_VERSION}-linux-x64.tar.gz -C /usr/local/ \
    && npm install "npm@v${NPM_VERSION}" -g

# Install git
yum -y install git