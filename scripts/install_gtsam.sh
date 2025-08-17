#!/bin/sh

# The GTSAM version string to use
VERSION=4.2

cd /

# Download the Protobuf version if not exists then unzip
git clone --depth 1 -b ${VERSION} https://github.com/borglab/gtsam.git
cd gtsam

# install deps for GTSAM
apt update
apt upgrade -y
apt install -y --no-install-recommends libboost-all-dev libeigen3-dev

# make a build directory for staging
mkdir build
cd build

# Configure GTSAM to build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_CXX_STANDARD=17 \
-D GTSAM_USE_SYSTEM_EIGEN=ON \
-D BUILD_TESTS=OFF \
..

# build it
make -j 5
make install

ldconfig

# clean up the installation
rm -rf /gtsam

# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean