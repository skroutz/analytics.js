FROM node:10.19.0
LABEL maintainer="analytics@skroutz.gr"
RUN apt-get -qq update
RUN rm /usr/local/bin/yarn && \
    rm /usr/local/bin/yarnpkg && \
    npm -g install yarn@1.13.0
WORKDIR /analytics.js
