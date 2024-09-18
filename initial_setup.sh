#!/bin/bash

echo "Installing required dependencies..."
sudo apt-get update
sudo apt install -y snapd
sudo apt-get install -y wget tar

DOTNET_SDK_URL="https://download.visualstudio.microsoft.com/download/pr/14742499-fc32-461e-bdb8-67b147763eee/c14113944f734526153f1aaac38ddfca/dotnet-sdk-8.0.401-linux-arm64.tar.gz"

echo "Downloading .NET SDK 8.0 for aarch64..."
wget $DOTNET_SDK_URL -O dotnet-sdk-8.0.100-linux-arm64.tar.gz

if [[ ! -f "dotnet-sdk-8.0.100-linux-arm64.tar.gz" ]]; then
    echo "Error: Failed to download .NET SDK. Please check the URL."
    exit 1
fi

echo "Creating directory for .NET SDK..."
mkdir -p $HOME/dotnet

echo "Extracting .NET SDK..."
tar -zxf dotnet-sdk-8.0.100-linux-arm64.tar.gz -C $HOME/dotnet

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
    rm dotnet-sdk-8.0.100-linux-arm64.tar.gz
else
    echo "Failed to install .NET SDK version 8.0. Please check for errors."
fi
