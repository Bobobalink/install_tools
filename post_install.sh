#!/usr/bin/env sh

ROS_DISTRO=kinetic

echo "Installing ROS distro $ROS_DISTRO"
sudo apt-get update --force-yes

sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net --recv-key 0xB01FA116

sudo apt-get --force-yes update
sudo apt-get --force-yes install python-wstool libgl1-mesa-dev-lts-utopic vim tmux screen git curl wget ros-$ROS_DISTRO-desktop-full
sudo apt-get --force-yes update

echo "Creating racecar-ws workspace"
mkdir -p ~/racecar-ws/src
cd ~/racecar-ws/src
source /opt/ros/$ROS_DISTRO/setup.bash
catkin_init_workspace
cd ~/racecar-ws
curl -L https://raw.githubusercontent.com/mit-racecar/racecar/master/racecar-vm.rosinstall > .rosinstall
wstool update

# Update 3rd party ROS deps
sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y -r


### INSTALL GAZEBO
echo "Installing Gazebo"

sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'

wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -

sudo apt-get --force-yes update

sudo apt-get --force-yes install ros-kinetic-controller-manager ros-kinetic-gazebo-ros-control ros-kinetic-gazebo-ros-pkgs ros-kinetic-joint-state-controller ros-kinetic-effort-controllers


echo "Setting up .bashrc"

cd ~/
curl -L https://raw.githubusercontent.com/mit-racecar/install_tools/master/bashrc_ending_vm.snippet >> ~/.bashrc
source ~/.bashrc


### SET UP ZED SDK

sudo apt-get --force-yes install ros-kinetic-pcl-*

# Jetson TX1
sudo apt-get --force-yes install libopencv4tegra-python
wget -U "Mozilla" -O ZED_SDK_v1.2.0.run https://www.stereolabs.com/download_327af3/ZED_SDK_Linux_JTX1_v1.2.0_64b_JetPack23.run

# Ubuntu
#wget -O ZED_SDK_v1.2.0.run https://www.stereolabs.com/download_327af3/ZED_SDK_Linux_Ubuntu16_CUDA80_v1.2.0.run

sh ZED_SDK_v1.2.0.run


### INSTALL URG NODE FOR HOKUYO
sudo apt-get --force-yes install ros-kinetic-urg-node

### MAPPING AND LOCALIZATION
sudo apt-get --force-yes install ros-kinetic-map-server ros-kinetic-gmapping ros-kinetic-amcl


### SET UP SOLACE PACKAGE
cd ~/racecar-ws/src/racecar
git clone https://github.com/TJ-Solace/solace.git
cd ~/racecar-ws
catkin_make
source ~/racecar-ws/devel/setup.bash
