FROM node:8.11.1
LABEL maintainer="analytics@skroutz.gr"
RUN apt-get -qq update
RUN npm -g install yarn@1.3.2 && chmod +x /usr/local/lib/node_modules/yarn/bin/yarn.js # https://github.com/nodejs/docker-node/issues/661
WORKDIR /analytics.js
