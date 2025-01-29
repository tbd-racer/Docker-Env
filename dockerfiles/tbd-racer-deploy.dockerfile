# Need an intial docker image that matches our kernel
FROM dustynv/cudnn:8.9-r36.2.0

# Define base env vars
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    PYTHONIOENCODING=utf-8 \
    DISTRO=ubuntu2204

COPY scripts/*.sh /

# Install opencv with CUDA enabled
RUN chmod +x /install_opencv.sh && /bin/sh -c /install_opencv.sh

# Install GTSAM
RUN chmod +x /install_gtsam.sh && /bin/sh -c /install_gtsam.sh

# Install the patched Apriltag library
RUN chmod +x /install_apriltag.sh && /bin/sh -c /install_apriltag.sh

# Install Sophus
RUN chmod +x /install_sophus.sh && /bin/sh -c /install_sophus.sh

# Install Phoenix6
RUN chmod +x /install_phoenix6.sh && /bin/sh -c /install_phoenix6.sh

ENV ROS_PACKAGE=ros_base
ENV ROS_DISTRO=jazzy
ENV ROS_ROOT=/opt/ros/jazzy
ENV ROS_PYTHON_VERSION=3
RUN chmod +x /install_ros2.sh && /bin/sh -c /install_ros2.sh

# Install PTP binaries
RUN chmod +x /install_ptp.sh && /bin/sh -c /install_ptp.sh


# setup the entrypoint
# commands will be appended/run by the entrypoint which sources the ROS environment
RUN chmod +x /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/bin/bash"]

WORKDIR /