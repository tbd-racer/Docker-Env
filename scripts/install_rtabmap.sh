#!/bin/bash

# The RTABMap version string to use
VERSION="0.22.1"

# Download the RTABMap version if not exists then unzip
git clone  --depth 1 -b ${VERSION} https://github.com/introlab/rtabmap.git
cd rtabmap

# make a build directory for staging
mkdir build
cd build

# Configure RTABMap to build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DBUILD_TESTS=OFF -DBUILD_APP=OFF -DBUILD_TOOLS=OFF \
  -DBUILD_EXAMPLES=OFF -DWITH_QT=OFF -DWITH_FREENECT=OFF -DWITH_FREENECT2=OFF \
  -DWITH_K4W2=OFF -DWITH_K4A=OFF -DWITH_ZED=OFF -DWITH_ZEDOC=OFF -DWITH_REALSENSE=OFF \
  -DWITH_REALSENSE_SLAM=OFF -DWITH_REALSENSE2=OFF -DWITH_MYNTEYE=OFF -DWITH_G2O=OFF \
  -DRTABMAP_USE_SYSTEM_EIGEN=ON \
  ..

# build it
make -j 4 install

