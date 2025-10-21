#!/usr/bin/env bash
# this script builds a ROS2 distribution from source
# ROS_DISTRO, ROS_ROOT environment variables should be set
export ROS_DISTRO=jazzy
export ROS_ROOT="/opt/ros/${ROS_DISTRO}/"
packages_file="/packages.list"
meta_file="/colcon.meta"

# If a packages.list file exists in the config directory, read package names from it
if [ -f "$packages_file" ]; then
	echo "Found packages list: $packages_file"
	# Read non-empty, non-comment lines, trim whitespace, and join with spaces
	mapfile -t pkg_lines < <(grep -vE '^\s*(#|$)' "$packages_file" | sed 's/^\s*//;s/\s*$//')
	if [ ${#pkg_lines[@]} -gt 0 ]; then
		pkg_args=("${pkg_lines[@]}")
	fi
fi

# otherwise, pkg_args will be empty and we can throw a fit
if [ -z "${pkg_args+x}" ]; then
	echo "No packages.list found or it is empty!"
	exit 1
fi

echo "ROS2 builder => ROS_DISTRO=$ROS_DISTRO ROS_ROOT=$ROS_ROOT"
echo "Packages to install: ${pkg_args[*]}"

set -e
#set -x

# add the ROS deb repo to the apt sources list
apt-get update
apt-get install -y --no-install-recommends \
		curl \
		wget \
		gnupg2 \
		lsb-release \
		ca-certificates \
		locales

# generate the locale info
locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# set the python version we want
update-alternatives --install /usr/bin/python python /usr/bin/python3 1

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
apt-get update

# install development packages
apt-get install -y --no-install-recommends \
		libbullet-dev \
		libpython3-dev \
		python3-colcon-common-extensions \
		python3-flake8 \
		python3-pip \
		python3-numpy \
		python3-pytest-cov \
		python3-rosdep \
		python3-setuptools \
		python3-vcstool \
		python3-rosinstall-generator \
		libasio-dev \
		libtinyxml2-dev \
		libcunit1-dev \
		libpcap-dev \
        libudev-dev

# remove other versions of Python3
# workaround for 'Could NOT find Python3 (missing: Python3_NumPy_INCLUDE_DIRS Development'
apt purge -y python3.9 libpython3.9* || echo "python3.9 not found, skipping removal"
ls -ll /usr/bin/python*

pip install fastapi uvicorn
    
# create the ROS_ROOT directory
mkdir -p ${ROS_ROOT}/src
cd ${ROS_ROOT}
    
# download ROS sources
# https://answers.ros.org/question/325245/minimal-ros2-installation/?answer=325249#post-id-325249

# Call rosinstall_generator with the package args
rosinstall_file=ros2.${ROS_DISTRO}.rosinstall
rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ${pkg_args[@]} > $rosinstall_file
vcs import --retry 5 --shallow src < $rosinstall_file

# support for plyon cameras
git clone https://github.com/coalman321/pylon-ros-camera.git -b humble src/pylon-ros-camera

# micro-ros support with CAN agent
git clone https://github.com/tbd-racer/micro-ROS-Agent.git -b jazzy src/micro-ros-agent
git clone https://github.com/micro-ROS/micro_ros_msgs.git -b humble src/micro-ros-msgs
git clone https://github.com/tbd-racer/Micro-XRCE-DDS-Agent.git -b can-support-jazzy src/micro-xrce-dds-agent

# ZED camera support
# git clone https://github.com/stereolabs/zed-ros2-wrapper.git -b master src/zed-ros2-wrapper
    
# https://github.com/dusty-nv/jetson-containers/issues/181
rm -r ${ROS_ROOT}/src/ament_cmake
git -C ${ROS_ROOT}/src/ clone https://github.com/ament/ament_cmake -b ${ROS_DISTRO}

# skip installation of some conflicting packages
SKIP_KEYS="libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv
 rti-connext-dds-6.0.1 microxrcedds_agent"
    
echo "--skip-keys $SKIP_KEYS"
    
# install dependencies using rosdep
rosdep init || true
rosdep update
rosdep install -y \
	--ignore-src \
	--from-paths src \
	--rosdistro ${ROS_DISTRO} \
	--skip-keys "$SKIP_KEYS"

export MAKEFLAGS="-j4" # Can be ignored if you have a lot of RAM (>16GB)

# build it all - for verbose, see https://answers.ros.org/question/363112/how-to-see-compiler-invocation-in-colcon-build
colcon build \
	--merge-install \
	--cmake-args -DCMAKE_BUILD_TYPE=Release \
	--metas $meta_file
    
# remove build files
rm -rf ${ROS_ROOT}/src
rm -rf ${ROS_ROOT}/logs
rm -rf ${ROS_ROOT}/build
rm ${ROS_ROOT}/*.rosinstall
    
# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean