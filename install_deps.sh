#!/bin/bash
# Install dependencies for GLOMAP
echo "Installing dependencies for GLOMAP"

# Check if linux or mac
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "Linux detected"
    if ! sudo apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    libboost-program-options-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libeigen3-dev \
    libflann-dev \
    libfreeimage-dev \
    libmetis-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libgmock-dev \
    libsqlite3-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libceres-dev; then
        echo "Error installing dependencies on Linux"
        exit 1
    else
        echo "Successfully installed dependencies on Linux"
    fi

    # If cuda is installed
    if [ -x "$(command -v nvcc)" ]; then
        echo "CUDA detected"
        if ! sudo apt-get install -y \
        nvidia-cuda-toolkit \
        nvidia-cuda-toolkit-gcc; then
            echo "Error installing CUDA toolkit on Linux"
            exit 1
        else
            echo "Successfully installed CUDA toolkit on Linux"
        fi
    else
        echo "CUDA not detected"
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Mac detected"
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found, please install it first."
        exit 1
    fi

    # Install dependencies on macOS
    echo "Installing dependencies using Homebrew"
    if ! brew install \
    cmake \
    ninja \
    boost \
    eigen \
    flann \
    freeimage \
    metis \
    glog \
    googletest \
    ceres-solver \
    qt5 \
    glew \
    cgal \
    sqlite3; then
        echo "Error installing dependencies on macOS"
        exit 1
    else
        echo "Successfully installed dependencies on macOS"
    fi
fi
