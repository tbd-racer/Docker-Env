#!/bin/bash
set -e
install_opencv () {

    # Read the model information from /proc/device-tree/model and remove null bytes
    model="Orin"
    # Check if the model information contains "Jetson Nano Orion"
    echo ""
    if [[ $model == *"Orin"* ]]; then
        echo "Detecting a Jetson Nano Orin."
    # Use always "-j 4"
        NO_JOB=4
        ARCH=8.7
        PTX="sm_87"
    elif [[ $model == *"Jetson Nano"* ]]; then
        echo "Detecting a regular Jetson Nano."
        ARCH=5.3
        PTX="sm_53"
    # Use "-j 4" only swap space is larger than 5.5GB
    FREE_MEM="$(free -m | awk '/^Swap/ {print $2}')"
    if [[ "FREE_MEM" -gt "5500" ]]; then
    NO_JOB=4
    else
    echo "Due to limited swap, make only uses 1 core"
    NO_JOB=1
    fi
    else
        echo "Unable to determine the Jetson Nano model."
        exit 1
    fi
    echo ""

    echo "Installing OpenCV 4.10.0"

    # reveal the CUDA location
    cd ~
    sh -c "echo '/usr/local/cuda/lib64' >> /etc/ld.so.conf.d/nvidia-tegra.conf"
    ldconfig

    # install the common dependencies
    apt update
    apt install -y --no-install-recommends \
    libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev \
    libpng-dev libtiff-dev libglew-dev \
    libavcodec-dev libavformat-dev libswscale-dev \
    python3-pip \
    libxvidcore-dev libx264-dev \
    libtbb-dev libxine2-dev \
    libv4l-dev v4l-utils qv4l2 \
    libtesseract-dev libpostproc-dev \
    libvorbis-dev \
    libfaac-dev libmp3lame-dev libtheora-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev \
    libopenblas-dev libatlas-base-dev libblas-dev \
    liblapack-dev liblapacke-dev libeigen3-dev gfortran \
    libhdf5-dev libprotobuf-dev protobuf-compiler \
    libgoogle-glog-dev libgflags-dev \
    tensorrt-dev

    # remove old versions or previous builds
    cd ~ 
    rm -rf opencv*
    # download the latest version
    git clone --depth=1 https://github.com/opencv/opencv.git -b "4.10.0"
    git clone --depth=1 https://github.com/opencv/opencv_contrib.git -b "4.10.0"

    # set install dir
    cd ~/opencv
    mkdir build
    cd build

    # run cmake
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
    -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
    -D WITH_OPENCL=OFF \
    -D CUDA_ARCH_BIN=${ARCH} \
    -D CUDA_ARCH_PTX=${PTX} \
    -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D WITH_CUBLAS=ON \
    -D ENABLE_FAST_MATH=ON \
    -D CUDA_FAST_MATH=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D WITH_NVCUVID=OFF \
    -D WITH_NVCUVENC=OFF \
    -D WITH_QT=OFF \
    -D WITH_OPENMP=ON \
    -D BUILD_TIFF=ON \
    -D WITH_FFMPEG=ON \
    -D WITH_GSTREAMER=ON \
    -D BUILD_TESTS=OFF \
    -D WITH_EIGEN=ON \
    -D WITH_V4L=ON \
    -D WITH_LIBV4L=ON \
    -D WITH_PROTOBUF=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_EXAMPLES=OFF \
    -D CMAKE_CXX_FLAGS="-march=native -mtune=native" \
    -D CMAKE_C_FLAGS="-march=native -mtune=native" ..

    make -j 6

    directory="/usr/include/opencv4/opencv2"
    if [ -d "$directory" ]; then
        # Directory exists, so delete it
        rm -rf "$directory"
    fi

    make install
    ldconfig

    # cleaning (frees 320 MB)
    make clean
    apt-get update
}

cd ~

if [ -d ~/opencv/build ]; then
  echo " "
  echo "You have a directory ~/opencv/build on your disk."
  echo "Continuing the installation will replace this folder."
  echo " "
  
  printf "Do you wish to continue (Y/n)?"
  read answer

  if [ "$answer" != "${answer#[Nn]}" ] ;then 
      echo "Leaving without installing OpenCV"
  else
      install_opencv
  fi
else
    install_opencv
fi
