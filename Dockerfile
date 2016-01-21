FROM node:0.10
MAINTAINER Dimitris Zorbas "zorbash@skroutz.gr"
ENV PATH ./node_modules/.bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN apt-get -qq update
RUN npm -g install bower
RUN npm -g install npm@1.4.29
WORKDIR /analytics.js
