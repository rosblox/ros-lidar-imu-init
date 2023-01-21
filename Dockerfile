FROM ros:noetic-ros-core

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential wget \
    libgoogle-glog-dev libgflags-dev libatlas-base-dev \
    ros-${ROS_DISTRO}-eigen-conversions ros-${ROS_DISTRO}-rviz ros-${ROS_DISTRO}-pcl-ros \
    && rm -rf /var/lib/apt/lists/*

COPY ceres-solver ceres-solver
WORKDIR /ceres-solver/ceres-bin
RUN cmake .. && make -j4 && make test && make install

WORKDIR /catkin_ws/src
COPY LiDAR_IMU_Init LiDAR_IMU_Init
COPY livox_ros_driver livox_ros_driver

WORKDIR /catkin_ws
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && catkin_make --cmake-args -DCMAKE_BUILD_TYPE=Release

WORKDIR /
COPY resources/ros_entrypoint.sh .

# Download bag file
ARG GDRIVE_BAGFILE_ID=1_fB3QSjtkaYItV1xUrtk8DdwuK4y9fyB
ARG GDRIVE_BAGFILE_NAME=avia_apartment.bag
ENV GDRIVE_BAGFILE_NAME=${GDRIVE_BAGFILE_NAME}

RUN wget -q --load-cookies /tmp/cookies.txt \ 
    "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=$GDRIVE_BAGFILE_ID' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$GDRIVE_BAGFILE_ID" -O $GDRIVE_BAGFILE_NAME && rm -rf /tmp/cookies.txt


WORKDIR /catkin_ws

RUN echo 'alias build="catkin_make --cmake-args -DCMAKE_BUILD_TYPE=Release"' >> ~/.bashrc
RUN echo 'alias run="roslaunch lidar_imu_init docker_livox_avia.launch"' >> ~/.bashrc
