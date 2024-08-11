#!/bin/bash

# Filename: cudainstall_robotics.sh
# Author: Saptarshi Chakrabarti
# 
# Description:
# This script automates the installation of Python 3.7, CUDA Toolkit 11.1, and
# essential robotics libraries on an Ubuntu 20.04 system. It also clones
# specific repositories into a robotics workspace and configures environment
# variables for CUDA.
#
# Usage:
# ./cudainstall_robotics.sh [PYTHON_VERSION] [CUDA_VERSION]
#
# Parameters:
# PYTHON_VERSION (optional): Specify the Python version to install (default: 3.7).
# CUDA_VERSION (optional): Specify the CUDA version to install (default: 11.1).
#
# The script logs its activities to 'cudainstall_robotics.log' and requires
# superuser privileges for certain operations.
#
# Compatibility:
# - Ubuntu 20.04

set -e  # Exit immediately if a command exits with a non-zero status

PYTHON_VERSION=${1:-3.7}  # Default Python version 3.7 if not provided
CUDA_VERSION=${2:-11.1}   # Default CUDA version 11.1 if not provided
OS_VERSION=$(lsb_release -sr)

# Log file to capture installation details
LOG_FILE="cudainstall_robotics.log"
exec > >(tee -i $LOG_FILE) 2>&1

echo "Starting installation process..."

# Check for Ubuntu 20.04 compatibility
if [ "$OS_VERSION" != "20.04" ]; then
    echo "Error: This script is designed for Ubuntu 20.04. Detected version: $OS_VERSION"
    exit 1
fi

# Check if Python 3.7 is already installed
if python3.7 --version &>/dev/null; then
    echo "Python $PYTHON_VERSION is already installed."
else
    echo "Adding deadsnakes PPA for Python $PYTHON_VERSION..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa

    echo "Installing Python $PYTHON_VERSION..."
    sudo apt-get update
    sudo apt-get install -y python${PYTHON_VERSION} libpython${PYTHON_VERSION}
fi

# Check if the required libraries are already installed
if dpkg -l | grep -q libsuitesparse-dev; then
    echo "libsuitesparse-dev is already installed."
else
    echo "Installing required libraries..."
    sudo apt-get install -y libsuitesparse-dev
fi

# Check if the robotics directory already exists
if [ ! -d "$HOME/Documents/robotics" ]; then
    echo "Setting up robotics workspace..."
    mkdir -p ~/Documents/robotics
else
    echo "Robotics workspace already exists."
fi

cd ~/Documents/robotics

# Clone repositories only if they don't exist
REPOS=("mesh_to_sdf" "storm" "grasp_diffusion")
REPO_URLS=(
    "https://github.com/robotgradient/mesh_to_sdf.git"
    "https://github.com/saptarshichakrabarti/storm.git"
    "https://github.com/saptarshichakrabarti/grasp_diffusion.git"
)

for i in "${!REPOS[@]}"; do
    if [ ! -d "${REPOS[$i]}" ]; then
        echo "Cloning ${REPOS[$i]}..."
        git clone "${REPO_URLS[$i]}"
    else
        echo "Repository ${REPOS[$i]} already exists."
    fi
done

echo "-- Installing CUDA Toolkit $CUDA_VERSION --"
CUDA_REPO_PIN="cuda-ubuntu2004.pin"
CUDA_REPO_DEB="cuda-repo-ubuntu2004-$CUDA_VERSION-local_11.1.0-455.23.05-1_amd64.deb"
CUDA_REPO_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64"
CUDA_LOCAL_INSTALLER="https://developer.download.nvidia.com/compute/cuda/$CUDA_VERSION.0/local_installers/$CUDA_REPO_DEB"

# Download and install CUDA only if not already installed
if ! dpkg -l | grep -q cuda-$CUDA_VERSION; then
    wget "$CUDA_REPO_URL/$CUDA_REPO_PIN"
    sudo mv $CUDA_REPO_PIN /etc/apt/preferences.d/cuda-repository-pin-600

    wget "$CUDA_LOCAL_INSTALLER"
    sudo dpkg -i $CUDA_REPO_DEB
    sudo apt-key add /var/cuda-repo-ubuntu2004-$CUDA_VERSION-local/7fa2af80.pub

    echo "Updating package lists and installing CUDA $CUDA_VERSION..."
    sudo apt-get update
    sudo apt-get install -y cuda-$CUDA_VERSION cuda-toolkit-$CUDA_VERSION
else
    echo "CUDA $CUDA_VERSION is already installed."
fi

echo "-- Adding CUDA environment variables to ~/.zshrc --"
{
    echo "export PATH=\"/usr/local/cuda-$CUDA_VERSION/bin:\$PATH\""
    echo "export LD_LIBRARY_PATH=\"/usr/local/cuda-$CUDA_VERSION/lib64:\$LD_LIBRARY_PATH\""
    echo "export CUDA_HOME=/usr/local/cuda-$CUDA_VERSION"
} >> ~/.zshrc

echo "Installation complete."

# Prompt for reboot
read -p "Reboot is required to apply changes. Do you want to reboot now? (y/n): " REBOOT
if [[ $REBOOT =~ ^[Yy]$ ]]; then
    echo "Rebooting now..."
    sudo reboot
else
    echo "Please reboot your system later to complete the installation."
fi

