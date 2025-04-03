# Need an intial docker image that matches our kernel
FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

# Define base env vars
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    DISTRO=ubuntu2204

COPY scripts/*.sh /

# Upgrade the containers opencv version
RUN chmod +x /install_opencv.sh && /bin/sh -c /install_opencv.sh

# Install Apriltag
RUN chmod +x /install_apriltag.sh && /bin/sh -c /install_apriltag.sh

# Install GTSAM
RUN chmod +x /install_gtsam.sh && /bin/sh -c /install_gtsam.sh

# Install Sophus
RUN chmod +x /install_sophus.sh && /bin/sh -c /install_sophus.sh

# Install Phoenix6
RUN chmod +x /install_phoenix6.sh && /bin/sh -c /install_phoenix6.sh

# Install Pylon
RUN chmod +x /install_pylon.sh && /bin/sh -c /install_pylon.sh

# Install ROS2 Jazzy
ENV ROS_PACKAGE=ros_base
ENV ROS_DISTRO=jazzy
ENV ROS_ROOT=/opt/ros/jazzy
ENV ROS_PYTHON_VERSION=3
RUN chmod +x /install_ros2.sh && /bin/sh -c /install_ros2.sh

# Install PTP binaries
RUN chmod +x /install_ptp.sh && /bin/sh -c /install_ptp.sh

# Install Development Tools
RUN chmod +x /install_dev_tools.sh && /bin/sh -c /install_dev_tools.sh

# setup the entrypoint
# commands will be appended/run by the entrypoint which sources the ROS environment
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

WORKDIR /

