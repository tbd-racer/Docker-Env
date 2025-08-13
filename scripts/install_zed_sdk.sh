#!/bin/bash

# Version information (SDK 5.0)
ZED_SDK_MAJOR="5"
ZED_SDK_MINOR="0"

DEPLOY_VERSION="l4t36.4/jetsons"

# select the SDK URL
SDK_URL="https://download.stereolabs.com/zedsdk/${ZED_SDK_MAJOR}.${ZED_SDK_MINOR}/"
SDK_URL+=$DEPLOY_VERSION

# Download the installer
echo "Downloading SDK ${SDK_URL}"
wget -q --no-check-certificate -O ZED_SDK_Linux.run ${SDK_URL}
chmod +x ZED_SDK_Linux.run

# install packages
apt update
apt install -y --no-install-recommends lsb-release wget less udev zstd \
    libpng-dev libgomp1 


# install the SDK
./ZED_SDK_Linux.run silent runtime_only skip_drivers
rm -rf /usr/local/zed/resources/* 
rm -rf ZED_SDK_Linux.run

# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt clean
