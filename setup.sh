#!/bin/bash

echo "Installing required dependencies..."
sudo apt-get update
sudo apt install -y snapd
sudo apt-get install -y wget tar

echo "Select the target architecture for .NET SDK installation:"
echo "1) x64"
echo "2) arm64 (aarch64)"
read -p "Enter the number corresponding to your architecture: " arch_choice

case $arch_choice in
    1)
        ARCH="x64"
        DOTNET_SDK_URL="https://download.visualstudio.microsoft.com/download/pr/db901b0a-3144-4d07-b8ab-6e7a43e7a791/4d9d1b39b879ad969c6c0ceb6d052381/dotnet-sdk-8.0.401-linux-x64.tar.gz"
        ;;
    2)
        ARCH="arm64"
        DOTNET_SDK_URL="https://download.visualstudio.microsoft.com/download/pr/14742499-fc32-461e-bdb8-67b147763eee/c14113944f734526153f1aaac38ddfca/dotnet-sdk-8.0.401-linux-arm64.tar.gz"
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

echo "Downloading .NET SDK 8.0 for $ARCH..."
wget $DOTNET_SDK_URL -O dotnet-sdk-8.0.100-linux-$ARCH.tar.gz

if [[ ! -f "dotnet-sdk-8.0.100-linux-$ARCH.tar.gz" ]]; then
    echo "Error: Failed to download .NET SDK. Please check the URL."
    exit 1
fi

echo "Creating directory for .NET SDK..."
mkdir -p $HOME/dotnet

echo "Extracting .NET SDK..."
tar -zxf dotnet-sdk-8.0.100-linux-$ARCH.tar.gz -C $HOME/dotnet

echo "Adding .NET to the PATH..."
export DOTNET_ROOT=$HOME/dotnet
export PATH=$HOME/dotnet:$PATH

echo "Updating .bashrc to include .NET in the PATH..."
echo "export DOTNET_ROOT=\$HOME/dotnet" >> ~/.bashrc
echo "export PATH=\$HOME/dotnet:\$PATH" >> ~/.bashrc

echo "Verifying .NET installation..."
dotnet_version=$(dotnet --version)

if [[ $dotnet_version == 8.* ]]; then
    echo ".NET SDK version $dotnet_version successfully installed!"
    rm dotnet-sdk-8.0.100-linux-$ARCH.tar.gz
else
    echo "Failed to install .NET SDK version 8.0. Please check for errors."
fi
