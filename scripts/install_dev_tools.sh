#!/usr/bin/env bash
# this script builds a ROS2 distribution from source

# install GDB and trt dev for dev image
apt-get update
apt-get install -y --no-install-recommends gdb tensorrt-dev

# Add LLVM GPG key
echo "Adding LLVM GPG key..."
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc > /dev/null

# Add LLVM repository for Ubuntu 22.04 (Jammy)
echo "Adding LLVM repository..."
echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy main" | sudo tee /etc/apt/sources.list.d/llvm-22.list > /dev/null

# Clean up any old LLVM repository entries that might conflict
sudo rm -f /etc/apt/sources.list.d/archive_uri-http_apt_llvm_org_jammy_-jammy.list

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install clangd-22
echo "Installing clangd-22..."
sudo apt-get install -y clangd-22
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-22 100
clangd --version

# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean