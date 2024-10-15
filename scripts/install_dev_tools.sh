#!/usr/bin/env bash
# this script builds a ROS2 distribution from source

# install GDB
apt-get update
apt-get install -y --no-install-recommends gdb 

# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean