FROM node:4.8.2
LABEL maintainer="analytics@skroutz.gr"
RUN echo '{ "allow_root": true }' > /root/.bowerrc # https://github.com/bower/bower/issues/1752
RUN apt-get -qq update
RUN npm -g install yarn@1.3.2
WORKDIR /analytics.js
