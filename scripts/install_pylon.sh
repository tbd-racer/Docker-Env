#!/bin/bash

ARCH="$(dpkg --print-architecture)"

echo "Detected architecture $ARCH"

if [ ! -f ./pylon.tar.gz ]; then
    rm -rf ./pylon_install ./pylon.tar.gz
fi

if [ $ARCH == "arm64" ]; then 
    wget -O pylon.tar.gz https://downloads-ctf.baslerweb.com/dg51pdwahxgw/2n0895dRYhYMngejm33gao/1302df1b607a8197feadda7e739645de/pylon-7.5.0.15658-linux-aarch64_setup.tar.gz
else 
    wget -O pylon.tar.gz https://downloads-ctf.baslerweb.com/dg51pdwahxgw/2Yng7CRH1jg02IKHvbUsNR/6adf0ef8b4d37cd33d37f432065893b8/pylon-7.5.0.15658_linux-x86_64_setup.tar.gz
fi

mkdir -p ./pylon_install
tar -xf ./pylon.tar.gz -C ./pylon_install


mkdir -p /opt/pylon
tar -C /opt/pylon -xzf ./pylon_install/pylon-*.tar.gz
chmod 755 /opt/pylon

rm -rf ./pylon_install
