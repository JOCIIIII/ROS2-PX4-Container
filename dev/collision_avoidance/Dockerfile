ARG BASEIMAGE
ARG BASETAG                           

FROM ${BASEIMAGE}:${BASETAG} AS base

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
    
# COPY REQUIRED APT PACKAGE LIST

USER root

COPY aptDeps.txt /tmp/aptDeps.txt

RUN apt-get update \
    && apt install software-properties-common -y  \
    && add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        $(cat /tmp/aptDeps.txt)

COPY --chown=user:user \
    pyDeps.txt /tmp/pyDeps.txt

# INSTALL PYTHON DEPENDENCIES
# AIRSIM PACKAGE MUST BE INSTALLED LATER THAN MSGPACK-RPC-PYTHON
RUN \
    python3 -m pip install \
        $(cat /tmp/pyDeps.txt) \
    && sudo rm -rf /tmp/* 
USER user
WORKDIR /home/user

RUN \
    mkdir -p /home/user/ros_ws/src 

COPY --chown=user:user \
    collision_avoidance /home/user/ros_ws/src/collision_avoidance
COPY --chown=user:user \
    custom_msgs /home/user/ros_ws/src/custom_msgs
COPY --chown=user:user \
    common_interfaces /home/user/ros_ws/src/common_interfaces
# ENTRYPOINT SCRIPT
# SET PERMISSION SO THAT USER CAN EDIT INSIDE THE CONTAINER
COPY --chown=user:user entrypoint.sh \
    /usr/local/bin/entrypoint.sh

RUN \
    source /opt/ros/galactic/setup.bash \
    && cd ${HOME}/ros_ws \
    && colcon build --symlink-install

RUN \
    rm -rf ${HOME}/scripts/entrypoint.sh \
    && sudo ln -s /usr/local/bin/entrypoint.sh /home/user/scripts/entrypoint.sh

RUN \
    echo "source ${HOME}/ros_ws/install/setup.bash" >> ${HOME}/.bashrc \
    && echo "source ${HOME}/ros_ws/install/setup.zsh" >> ${HOME}/.zshrc


CMD [ "/usr/local/bin/entrypoint.sh" ]

# --------------- BUILD COMMAND ---------------
# DOCKER_BUILDKIT=1 docker build --no-cache \
# --build-arg BASEIMAGE=jociiiii/ros2 \
# --build-arg BASETAG=dev-galactic-tensorrt2212 \
# -t jociiiii/ros2:dev-galactic-tensorrt2212-ca-v0.9 \
# -f ./Dockerfile .


# docker buildx build \
# --progress=plain \
# --platform=linux/arm64/v8,linux/amd64 \
# --build-arg BASEIMAGE=ubuntu \
# --build-arg BASETAG=22.04 \
# -t kestr3l/ros2:dev-humble \
# -f ./Dockerfile .

# ------- BUILD COMMAND (AMD64 CUDA) ------
# docker buildx build \
# --progress=plain \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.8.0-devel-ubuntu22.04 \
# -t kestr3l/ros2:dev-humble-cu1181d \
# -f ./Dockerfile .

# ------- BUILD COMMAND (ARM64 L4T) -------
# docker buildx build \
# --progress=plain \
# --platform=linux/arm64/v8 \
# --build-arg BASEIMAGE=nvcr.io/nvidia/l4t-ml \
# --build-arg BASETAG=r35.2.1-py3 \
# -t kestr3l/ros2:dev-humble-l4t-ml \
# -f ./Dockerfile .
