#!/bin/bash

# Filename: cudainstall_robotics.sh
# Author: Saptarshi Chakrabarti

sudo add-apt-repository ppa:deadsnakes/ppa
sudo aptinstall python3.7
sudo apt install libpython3.7
sudo apt install libsuitesparse-dev

cd Documents
mkdir robotics
cd robotics
git clone https://github.com/robotgradient/mesh_to_sdf.git
git clone https://github.com/saptarshichakrabarti/storm.git
git clone https://github.com/saptarshichakrabarti/grasp_diffusion.git


-- Installing CUDA Toolkit 11.1 --

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.1.0/local_installers/cuda-repo-ubuntu2004-11-1-local_11.1.0-455.23.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-1-local_11.1.0-455.23.05-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-1-local/7fa2af80.pub
sudo apt update
sudo apt -y install cuda-11-1
sudo apt -y install cuda-toolkit-11-1

-- add to ~/.zshrc
export PATH="/usr/local/cuda-11.1/bin:$PATH"
export LD_LIBRARY_PATH="/usr/local/cuda-11.1/lib64:$LD_LIBRARY_PATH"
export CUDA_HOME=/usr/local/cuda-11.1

sudo reboot now

-- Install Anaconda --



-- Create virtual environment --

-- install isaacgym --set mkl to 2024.0 in environment.yml
-- install mesh_to_sdf which was previously cloned
-- install theseus-ai
-- unzip the data folder in root folder - here in Documents/robotics
-- install grasp-difussion
-- install storm
