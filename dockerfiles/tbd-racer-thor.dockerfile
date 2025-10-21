# Jetpack 7 follows SBSA architecture. it is incompatible with the prior jetpack versions
FROM nvcr.io/nvidia/cuda:13.0.0-tensorrt-devel-ubuntu24.04

# Define base env vars
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    DISTRO=ubuntu2404

# Install newer version of CMAKE
COPY scripts/install_cmake.sh /
RUN /bin/sh -c /install_cmake.sh

# Install opencv with CUDA enabled
COPY scripts/install_opencv.sh /
RUN /bin/sh -c "/install_opencv.sh Thor"

# Install the patched Apriltag library
COPY scripts/install_apriltag.sh /
RUN /bin/sh -c /install_apriltag.sh

# Install Pylon
COPY scripts/install_pylon.sh /
RUN /bin/sh -c /install_pylon.sh

# Install PTP binaries
COPY scripts/install_ptp.sh /
RUN /bin/sh -c /install_ptp.sh

# Install ROS2 Jazzy packages
ENV ROS_DISTRO=jazzy
ENV ROS_ROOT=/opt/ros/jazzy
ENV ROS_PYTHON_VERSION=3
COPY scripts/install_ros2.sh scripts/ros_packages/thor /
RUN /bin/sh -c /install_ros2.sh

# setup the entrypoint
# commands will be appended/run by the entrypoint which sources the ROS environment
COPY scripts/ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

WORKDIR /