# Base Image
FROM ubuntu:jammy
ARG TARGETPLATFORM
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=ubuntu
ENV PASSWD=ubuntu
ARG NODE_MAJOR=20

# Set Shell
SHELL ["/bin/bash", "-c"]

# Install dependencies in a single layer
RUN apt-get update -q && \
    apt-get upgrade -y && \
    apt-get install -y ubuntu-mate-desktop \
    tigervnc-standalone-server tigervnc-common xorg dbus-x11 \
    supervisor wget ca-certificates curl gnupg nodejs xauth iputils-ping \
    gosu software-properties-common mosquitto mosquitto-clients \
    screen git sudo python3-pip tini gpg net-tools openbox telnet \
    build-essential vim sudo lsb-release locales ffmpeg \
    bash-completion tzdata terminator apt-transport-https && \
    pip3 install setuptools wheel numpy matplotlib scipy scikit-learn scikit-image pandas opencv-python && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Install NodeJS
RUN curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh && \
    chmod 500 nsolid_setup_deb.sh && \
    ./nsolid_setup_deb.sh ${NODE_MAJOR} && \
    apt-get install -y nodejs && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Clone and set up noVNC
RUN git clone https://github.com/novnc/noVNC.git /usr/lib/novnc && \
    pip3 install git+https://github.com/novnc/websockify.git && \
    ln -s /usr/lib/novnc/vnc.html /usr/lib/novnc/index.html && \
    sed -i "s/UI.initSetting('resize', 'off');/UI.initSetting('resize', 'remote');/g" /usr/lib/novnc/app/ui.js

# Disable auto-update and crash report
RUN sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades && \
    sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

# Install additional repositories
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 501' >> /etc/apt/preferences.d/mozilla-firefox && \
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null && \
    echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    rm -f packages.microsoft.gpg

# Install ROS2
ENV ROS_DISTRO=humble
ARG INSTALL_PACKAGE=desktop-full
RUN add-apt-repository universe && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install all other packages
RUN apt-get update -q && \
    apt-get install -y \
    firefox sublime-text code ros-${ROS_DISTRO}-${INSTALL_PACKAGE} \
    ros-${ROS_DISTRO}-ros-base ros-dev-tools python3-argcomplete \
    python3-colcon-common-extensions python3-rosdep python3-vcstool \
    ros-${ROS_DISTRO}-ros-gz ros-${ROS_DISTRO}-rmw-cyclonedds-cpp && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set up ROS2
RUN rosdep init && \
    rosdep update

# Enable apt-get completion
RUN rm /etc/apt/apt.conf.d/docker-clean

# Entry Point
COPY ./entrypoint.sh /
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]