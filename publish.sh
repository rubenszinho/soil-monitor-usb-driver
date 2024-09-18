#!/bin/bash

echo "Publishing the project..."

echo "Select the target architecture for publishing the project:"
echo "1) x64"
echo "2) arm64 (aarch64)"
read -p "Enter the number corresponding to your architecture: " arch_choice

case $arch_choice in
    1)
        ARCH="linux-x64"
        ;;
    2)
        ARCH="linux-arm64"
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

dotnet publish -c Release -r $ARCH --self-contained

echo "Making the file executable..."
sudo chmod +x bin/Release/net8.0/$ARCH/publish/DriverUSB

echo "Adding the user to the dialout group..."
sudo usermod -aG dialout $USER

echo "You need to log out and log back in for the group changes to take effect."

echo "Setup complete!"
echo "To run the application, navigate to the publish directory and execute:"
echo "cd bin/Release/net8.0/$ARCH/publish/"
echo "./DriverUSB"
