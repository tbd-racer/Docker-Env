# Need an intial docker image that matches our kernel
FROM dustynv/onnxruntime:1.22-r36.4.0-cu128-24.04

# Define base env vars
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    DISTRO=ubuntu2204

# Install newer version of CMAKE
# can skip this now since we are using a base image that has cmake 3.31
# COPY scripts/install_cmake.sh /
# RUN /bin/sh -c /install_cmake.sh

# Install opencv with CUDA enabled
COPY scripts/install_opencv.sh /
RUN /bin/sh -c /install_opencv.sh

# Install Sophus
COPY scripts/install_sophus.sh /
RUN /bin/sh -c /install_sophus.sh

# Install Pylon
COPY scripts/install_pylon.sh /
RUN /bin/sh -c /install_pylon.sh

ENV ROS_PACKAGE=ros_base
ENV ROS_DISTRO=jazzy
ENV ROS_ROOT=/opt/ros/jazzy
ENV ROS_PYTHON_VERSION=3
COPY scripts/install_ros2.sh scripts/colcon.meta /
RUN /bin/sh -c /install_ros2.sh

# Install PTP binaries
COPY scripts/install_ptp.sh /
RUN /bin/sh -c /install_ptp.sh

# Install ZED SDK binaries
COPY scripts/install_zed_sdk.sh /
RUN /bin/sh -c /install_zed_sdk.sh deploy

# setup the entrypoint
# commands will be appended/run by the entrypoint which sources the ROS environment
COPY scripts/ros_entrypoint.sh /
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

WORKDIR /