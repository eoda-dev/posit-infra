#!/bin/sh
# System libraries needed to build common R packages from source
set -eu

sudo apt-get update
sudo apt-get install -y \
  build-essential gfortran pkg-config \
  libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev libssh2-1-dev \
  libfontconfig1-dev libfreetype6-dev libharfbuzz-dev libfribidi-dev \
  libcairo2-dev libpng-dev libjpeg-dev libtiff-dev \
  libicu-dev zlib1g-dev libbz2-dev liblzma-dev libsqlite3-dev \
  libblas-dev liblapack-dev
