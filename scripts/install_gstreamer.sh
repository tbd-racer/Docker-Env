#!/bin/bash
set -e

MODEL=$1
echo "Jetson Model: $MODEL"

install_gstreamer () {
    # Check if the model information contains "Jetson Nano Orion"
    echo ""
    if [[ $MODEL == *"Thor"* ]]; then
        echo "Detecting a Jetson Thor."
        GSTREAMER_VERSION="1.24"
    elif [[ $MODEL == *"Orin"* ]]; then
        echo "Detecting a Jetson Orin."
        GSTREAMER_VERSION="1.24"
    elif [[ $MODEL == *"Jetson Nano"* ]]; then
        echo "Detecting a regular Jetson Nano."
        GSTREAMER_VERSION="1.24"
    else
        echo "Unable to determine the Jetson model."
        exit 1
    fi
    echo ""

    echo "Installing GStreamer ${GSTREAMER_VERSION}..."

    # install the common dependencies
    apt update
    apt install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        ca-certificates \
        pkg-config \
        ninja-build \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        flex \
        bison \
        libmount-dev \
        libglib2.0-dev \
        libssl-dev \
        libxml2-dev \
        libpcre2-dev \
        zlib1g-dev \
        liborc-0.4-dev \
        libx11-dev \
        libx11-xcb-dev \
        libxcb1-dev \
        libxv-dev \
        libxt-dev \
        libxext-dev \
        libxrandr-dev \
        libxi-dev \
        libxfixes-dev \
        libxrender-dev \
        libxdamage-dev \
        libxcomposite-dev \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        libwayland-dev \
        wayland-protocols \
        libdrm-dev \
        libegl1-mesa-dev \
        libgles2-mesa-dev \
        libgl1-mesa-dev \
        libgbm-dev \
        libpulse-dev \
        libasound2-dev \
        libopus-dev \
        libvorbis-dev \
        libtheora-dev \
        libjpeg-dev \
        libpng-dev \
        libvpx-dev \
        libx264-dev \
        libx265-dev \
        libva-dev \
        libv4l-dev \
        v4l-utils \
        libgudev-1.0-dev \
        libjson-glib-dev \
        libsoup2.4-dev \
        libsrtp2-dev \
        libnice-dev \
        libwebrtc-audio-processing-dev \
        libmpg123-dev \
        libmp3lame-dev \
        libflac-dev \
        libcairo2-dev \
        libpango1.0-dev \
        librsvg2-dev \
        libvisual-0.4-dev \
        libcdparanoia-dev \
        libopenjp2-7-dev \
        libdvdnav-dev \
        libdvdread-dev \
        libass-dev \
        librtmp-dev \
        libfdk-aac-dev \
        libmpeg2-4-dev \
        liba52-0.7.4-dev \
        libfaad-dev \
        libwavpack-dev \
        libmodplug-dev \
        libsbc-dev \
        libbs2b-dev \
        libchromaprint-dev \
        liblilv-dev \
        libsoundtouch-dev \
        libsrt-gnutls-dev \
        libzbar-dev \
        libdc1394-dev \
        libaom-dev \
        libwebp-dev \
        libdav1d-dev \
        libsndfile1-dev \
        libspandsp-dev \
        libusrsctp-dev \
        libsrtp2-dev \
        libfreeaptx-dev

    # install meson build system
    pip3 install --upgrade meson

    # remove old versions or previous builds
    cd ~ 
    rm -rf gstreamer

    # create gstreamer directory
    mkdir -p ~/gstreamer
    cd ~/gstreamer

    # download gstreamer and all plugins
    echo "Cloning GStreamer repositories..."
    git clone --depth=1 https://gitlab.freedesktop.org/gstreamer/gstreamer.git -b $GSTREAMER_VERSION

    cd gstreamer
    
    # setup build directory
    meson setup build \
        --prefix=/usr \
        --buildtype=release \
        --wrap-mode=nofallback \
        -D gpl=enabled \
        -D gst-plugins-base:gl=enabled \
        -D gst-plugins-base:gl_platform=egl \
        -D gst-plugins-base:gl_winsys=wayland \
        -D gst-plugins-base:gl_api=gles2 \
        -D gst-plugins-base:x11=disabled \
        -D gst-plugins-base:xvideo=disabled \
        -D gst-plugins-base:xshm=disabled \
        -D gst-plugins-good:v4l2=enabled \
        -D gst-plugins-good:v4l2-probe=true \
        -D gst-plugins-good:rpicamsrc=disabled \
        -D gst-plugins-bad:nvcodec=enabled \
        -D gst-plugins-bad:kms=enabled \
        -D gst-plugins-bad:webrtc=enabled \
        -D gst-plugins-ugly:x264=enabled \
        -D gst-libav:libav=enabled \
        -D gst-rtsp-server:enabled=enabled \
        -D libnice:examples=disabled \
        -D libnice:gupnp=disabled \
        -D libnice:tests=disabled \
        -D python=disabled \
        -D examples=disabled \
        -D tests=disabled \
        -D doc=disabled \
        -D introspection=disabled \
        -D nls=disabled \
        -D orc=enabled \
        -D package-origin=https://gstreamer.freedesktop.org \
        -D package-name="GStreamer from source"

    # build gstreamer
    echo "Building GStreamer (this may take a while)..."
    ninja -C build -j $(nproc)

    # install gstreamer
    echo "Installing GStreamer..."
    ninja -C build install

    # update library cache
    ldconfig

    # verify installation
    echo "Verifying GStreamer installation..."
    gst-launch-1.0 --version
    gst-inspect-1.0 --version

    # cleanup
    echo "Cleaning up build files..."
    cd ~
    rm -rf ~/gstreamer

    # cleanup apt   
    rm -rf /var/lib/apt/lists/*
    apt-get clean
}

cd ~

if [ -d ~/gstreamer ]; then
  echo " "
  echo "You have a directory ~/gstreamer on your disk."
  echo "Continuing the installation will replace this folder."
  echo " "
  
  printf "Do you wish to continue (Y/n)?"
  read answer

  if [ "$answer" != "${answer#[Nn]}" ] ;then 
      echo "Leaving without installing GStreamer"
  else
      install_gstreamer
  fi
else
    install_gstreamer
fi
