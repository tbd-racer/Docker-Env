# Need an intial docker image that matches our kernel
FROM dustynv/cudnn:8.9-r36.2.0

# Define base env vars
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    DISTRO=ubuntu2204

# Install neweer version of CMAKE
COPY scripts/install_cmake.sh /
RUN /bin/sh -c /install_cmake.sh

# Install opencv with CUDA enabled
COPY scripts/install_opencv.sh /
RUN /bin/sh -c /install_opencv.sh

# Install GTSAM
COPY scripts/install_gtsam.sh /
RUN /bin/sh -c /install_gtsam.sh

# Install the patched Apriltag library
COPY scripts/install_apriltag.sh /
RUN /bin/sh -c /install_apriltag.sh

# Install Sophus
COPY scripts/install_sophus.sh /
RUN /bin/sh -c /install_sophus.sh

# Install Phoenix6
COPY scripts/install_phoenix6.sh /
RUN /bin/sh -c /install_phoenix6.sh

# Install Pylon
COPY scripts/install_pylon.sh /
RUN /bin/sh -c /install_pylon.sh

ENV ROS_PACKAGE=ros_base
ENV ROS_DISTRO=jazzy
ENV ROS_ROOT=/opt/ros/jazzy
ENV ROS_PYTHON_VERSION=3
COPY scripts/install_ros2.sh /
RUN /bin/sh -c /install_ros2.sh

# Install PTP binaries
COPY scripts/install_ptp.sh /
RUN /bin/sh -c /install_ptp.sh


# setup the entrypoint
# commands will be appended/run by the entrypoint which sources the ROS environment
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

WORKDIR /