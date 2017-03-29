FROM node:4.7
MAINTAINER Dimitris Zorbas "zorbash@skroutz.gr"
RUN echo '{ "allow_root": true }' > /root/.bowerrc # https://github.com/bower/bower/issues/1752
RUN apt-get -qq update
RUN npm -g install npm@2.15.11
RUN npm -g install yarn@0.21.3
WORKDIR /analytics.js
