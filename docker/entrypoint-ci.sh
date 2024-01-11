#!/bin/bash

set -ex

# Phantomjs expects the location of OPENSSL_CONF in
# a different system path. Since we upgraded to buster
# the OPENSSL_CONF can be found under /etc/ssl.
export OPENSSL_CONF=/etc/ssl

# fetch assets
yarn install

yarn run test
