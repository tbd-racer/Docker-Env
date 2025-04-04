#!/usr/bin/env bash
# this script builds a ROS2 distribution from source
# ROS_DISTRO, ROS_ROOT, ROS_PACKAGE environment variables should be set
export ROS_DISTRO=jazzy
export ROS_PACKAGE=ros_base
export ROS_ROOT="/opt/ros/${ROS_DISTRO}/"

echo "ROS2 builder => ROS_DISTRO=$ROS_DISTRO ROS_PACKAGE=$ROS_PACKAGE ROS_ROOT=$ROS_ROOT"

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
		libcunit1-dev

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
rosinstall_generator --deps --rosdistro ${ROS_DISTRO} ${ROS_PACKAGE} \
	launch_xml \
	launch_yaml \
	launch_testing \
	launch_testing_ament_cmake \
	demo_nodes_cpp \
	demo_nodes_py \
	example_interfaces \
	vision_msgs \
	xacro \
	robot_state_publisher \
	joint_state_publisher \
	rosbag2_storage_mcap \
	tf2_geometry_msgs \
	cv_bridge \
	image_transport \
	robot_localization \
	web_video_server \
	image_geometry \
	diagnostic_updater \
	camera_info_manager \
	pcl_ros \
> ros2.${ROS_DISTRO}.${ROS_PACKAGE}.rosinstall
cat ros2.${ROS_DISTRO}.${ROS_PACKAGE}.rosinstall
vcs import --retry 5 --shallow src < ros2.${ROS_DISTRO}.${ROS_PACKAGE}.rosinstall

git clone https://github.com/coalman321/pylon-ros-camera.git -b humble src/pylon-ros-camera
    
# https://github.com/dusty-nv/jetson-containers/issues/181
rm -r ${ROS_ROOT}/src/ament_cmake
git -C ${ROS_ROOT}/src/ clone https://github.com/ament/ament_cmake -b ${ROS_DISTRO}

# skip installation of some conflicting packages
SKIP_KEYS="libopencv-dev libopencv-contrib-dev libopencv-imgproc-dev python-opencv python3-opencv rti-connext-dds-6.0.1"

# patches for building Humble on 18.04
if [ "$ROS_DISTRO" = "humble" ] || [ "$ROS_DISTRO" = "iron" ] && [ $(lsb_release --codename --short) = "bionic" ]; then
	# rti_connext_dds_cmake_module: No definition of [rti-connext-dds-6.0.1] for OS version [bionic]
	SKIP_KEYS="$SKIP_KEYS rti-connext-dds-6.0.1 ignition-cmake2 ignition-math6"

	# the default gcc-7 is too old to build humble
	apt-get install -y --no-install-recommends gcc-8 g++-8
	export CC="/usr/bin/gcc-8"
	export CXX="/usr/bin/g++-8"
	echo "CC=$CC CXX=$CXX"

	# upgrade pybind11
	apt-get purge -y pybind11-dev
	pip3 install --upgrade --no-cache-dir pybind11-global
   
	# https://github.com/dusty-nv/jetson-containers/issues/160#issuecomment-1429572145
	git -C /tmp clone -b yaml-cpp-0.6.0 https://github.com/jbeder/yaml-cpp.git
	cmake -S /tmp/yaml-cpp -B /tmp/yaml-cpp/BUILD -DBUILD_SHARED_LIBS=ON
	cmake --build /tmp/yaml-cpp/BUILD --parallel $(nproc --ignore=1)
	cmake --install /tmp/yaml-cpp/BUILD
	rm -rf /tmp/yaml-cpp
fi
    
echo "--skip-keys $SKIP_KEYS"
    
# install dependencies using rosdep
rosdep init || true
rosdep update
rosdep install -y \
	--ignore-src \
	--from-paths src \
	--rosdistro ${ROS_DISTRO} \
	--skip-keys "$SKIP_KEYS"

# build it all - for verbose, see https://answers.ros.org/question/363112/how-to-see-compiler-invocation-in-colcon-build
colcon build \
	--merge-install \
	--cmake-args -DCMAKE_BUILD_TYPE=Release 
    
# remove build files
rm -rf ${ROS_ROOT}/src
rm -rf ${ROS_ROOT}/logs
rm -rf ${ROS_ROOT}/build
rm ${ROS_ROOT}/*.rosinstall
    
# cleanup apt   
rm -rf /var/lib/apt/lists/*
apt-get clean