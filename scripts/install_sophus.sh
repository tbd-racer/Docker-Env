#!/bin/bash

# The Sophus version string to use
VERSION="1.22.10"

# Download the Sophus version if not exists then unzip
git clone  --depth 1 -b ${VERSION} https://github.com/strasdat/Sophus.git
cd Sophus

# run the setup script
# dont have to run this for what we need
# ./scripts/install_ubuntu_deps_incl_ceres.sh

# make a build directory for staging
mkdir build
cd build

# Configure sophus to build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D BUILD_TESTS=OFF \
..

# build it
make -j
make install

