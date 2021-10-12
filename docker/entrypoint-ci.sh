#!/bin/bash

set -ex

# fetch assets
yarn install

yarn run test
