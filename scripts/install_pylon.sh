#!/bin/bash

ARCH="$(dpkg --print-architecture)"

echo "Detected architecture $ARCH"

if [ ! -f ./pylon.tar.gz ]; then
    rm -rf ./pylon_install ./pylon.tar.gz
fi

if [ $ARCH == "arm64" ]; then 
    wget -O pylon.tar.gz https://downloads-ctf.baslerweb.com/dg51pdwahxgw/3Vcb9BUDqGvdp7wkoHu5yd/1d9efba06df8683b3bc9cf328ea1f2b4/pylon-8.1.0_linux-aarch64_setup.tar.gz
else 
    wget -O pylon.tar.gz https://downloadbsl.blob.core.windows.net/software/pylon-8.1.0_linux-x86_64_setup.tar.gz
fi

mkdir -p ./pylon_install
tar -xf ./pylon.tar.gz -C ./pylon_install


mkdir -p /opt/pylon
tar -C /opt/pylon -xzf ./pylon_install/pylon-*.tar.gz
chmod 755 /opt/pylon

rm -rf ./pylon_install
