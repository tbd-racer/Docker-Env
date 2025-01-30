#!/bin/sh

# The Apriltag version string to use
VERSION=main

cd /

# Download the Apriltag version if not exists then unzip
git clone --depth 1 -b ${VERSION} https://github.com/coalman321/apriltag.git
cd apriltag

# make a build directory for staging
mkdir build
cd build

# Configure apriltag to build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D BUILD_TESTS=OFF \
..

# build it
make -j
make install

ldconfig

# clean up the installation
cd /
rm -rf /apriltag