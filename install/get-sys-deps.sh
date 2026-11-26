#!/bin/sh
# System libraries needed to build common R packages from source
set -eu

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  cmake \
  default-jdk \
  gdal-bin \
  gfortran \
  git \
  gsfonts \
  libabsl-dev \
  libblas-dev \
  libbz2-dev \
  libcairo2-dev \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libfribidi-dev \
  libgdal-dev \
  libgeos-dev \
  libgit2-dev \
  libgl1-mesa-dev \
  libglpk-dev \
  libglu1-mesa-dev \
  libharfbuzz-dev \
  libicu-dev \
  libjpeg-dev \
  liblapack-dev \
  liblzma-dev \
  libmagick++-dev \
  libmysqlclient-dev \
  libnode-dev \
  libpng-dev \
  libpoppler-cpp-dev \
  libproj-dev \
  libprotobuf-dev \
  libprotoc-dev \
  libsodium-dev \
  libsqlite3-dev \
  libssh2-1-dev \
  libssl-dev \
  libtiff-dev \
  libudunits2-dev \
  libuv1-dev \
  libwebp-dev \
  libx11-dev \
  libxml2-dev \
  make \
  pkg-config \
  poppler-data \
  protobuf-compiler \
  python3 \
  tcl \
  texlive \
  tk \
  tk-dev \
  tk-table \
  unixodbc-dev \
  zlib1g-dev
