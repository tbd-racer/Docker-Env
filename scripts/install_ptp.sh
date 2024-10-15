#!/bin/bash

# install ptp binaries
apt update
apt install --no-install-recommends -y linuxptp

# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean
