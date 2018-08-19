FROM resin/raspberrypi3-python:3.6
ENV INITSYSTEM on

LABEL maintainer="xnorpx@outlook.com"

RUN [ "cross-build-start" ]

RUN apt-get update && apt-get install -yq --no-install-recommends \
build-essential \
cmake \
pkg-config \ 
git \ 
wget \ 
unzip \ 
yasm \
libjpeg-dev \ 
libtiff5-dev \
libjasper-dev \
libpng12-dev \
libavcodec-dev \
libavformat-dev \
libswscale-dev \
libv4l-dev \
libxvidcore-dev \
libx264-dev \
libgtk2.0-dev \
libgtk-3-dev \
libcanberra-gtk* \
libatlas-base-dev \
gfortran \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && pip install numpy

WORKDIR /

ENV OPENCV_VERSION="3.4.2"
RUN wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip -qq ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake \
  -DENABLE_NEON=ON \
  -DENABLE_VFPV3=ON \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python) \
  -DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  -DBUILD_TESTS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DINSTALL_PYTHON_EXAMPLES=OFF \
  .. \
&& make -j make -j $(python -c "import multiprocessing as mp; print(int(mp.cpu_count() * 1.5))") -s \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}
RUN [ "cross-build-end" ]
