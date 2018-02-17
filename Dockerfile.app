ARG NODE_VERSION="8.9.2"
ARG NPM_VERSION="5.5.0"
ARG APP_REGISTRY="registry.devshift.net/fabric8-hdd"

FROM ${APP_REGISTRY}/nodejs:${NODE_VERSION}_npm_${NPM_VERSION}
LABEL maintainer="Anmol Babu <anmolbudugutta@gmail.com>"

# Install app dependencies
ADD package.json ./package.json
ADD package-lock.json ./package-lock.json
RUN npm install --production \
    && rm -fr ./package.json ./package-lock.json

# Setup App Dir
RUN mkdir -p /usr/src/app && mv -f ./node_modules /usr/src/app/
WORKDIR /usr/src/app

# Bundle app source
ADD . .

# Setup non-root user node
RUN groupadd -r node \
    && useradd -r -g node node
RUN chown -R node:node /usr/src/app

# Switch to non-root user
ENV USER node
USER node

ARG APP_PORT=9090
ENV APP_PORT ${APP_PORT}

# Expose port
EXPOSE ${APP_PORT}

# Start app
CMD [ "dumb-init", "npm", "start" ]

