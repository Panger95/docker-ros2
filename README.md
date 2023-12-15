# Requirements
1. Latest working version of Docker
2. At least 30gb of local hard drive space
3. Working version of git
4. ROS Workspace Directory

# Installing Resources
1. Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
2. Download [Docker Desktop](https://www.docker.com/products/docker-desktop/)
3. Create or navigate to your ROS2 Workspace Directory
4. Clone the git
    `git clone https://github.com/Panger95/docker-ros2.git`
5. Make sure Docker is running
6. Run the following commands below

# Creates the Docker image with the tag called ros2
docker build --tag 'ros2' .
# Runs the docker image with 5gb of space and mounts the current directory you are executing the image from
docker run -p 6080:80 -p 11311:11311 --privileged -v ./..:/home/ubuntu/ros2_ws -v /dev/shm:/dev/shm --name ros2 --security-opt seccomp=unconfined --shm-size=5gb -t ros2
# Connect to the image
http://127.0.0.1:6080/
# Reconnect to an existing container
docker start ros2
docker exec -t ros2 /bin/bash