#!/bin/bash

# make sure curl is installed
apt update
apt upgrade -y
apt install -y --no-install-recommends curl

# Based on https://v6.docs.ctr-electronics.com/en/latest/docs/installation/installation-nonfrc.html

export YEAR=2025
curl -s --compressed -o /usr/share/keyrings/ctr-pubkey.gpg "https://deb.ctr-electronics.com/ctr-pubkey.gpg"
curl -s --compressed -o /etc/apt/sources.list.d/ctr${YEAR}.list "https://deb.ctr-electronics.com/ctr${YEAR}.list"

# install just phoenix 6 library
apt update
apt install --no-install-recommends -y phoenix6

# add a config for ldconfig to look for ctre...
echo "/usr/lib/phoenix6" > /etc/ld.so.conf.d/20-ctre.conf

# regenerate the ldconfig so the libraries get picked up for runtime
ldconfig

# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean

