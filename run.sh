#!/bin/bash

xhost +

docker run -it --rm --privileged --net=host \
--volume $(pwd)/LiDAR_IMU_Init:/catkin_ws/src/LiDAR_IMU_Init \
-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
ghcr.io/rosblox/ros-lidar-imu-init:noetic