# USB Driver for the Landslide Soil Monitoring Station

## Project Overview

This project is a C# implementation of a USB driver that facilitates communication between a soil moisture monitoring station and a computer via a USB-to-Serial TTL conversion. The monitoring station collects data such as soil salinity, humidity, temperature, and other environmental metrics, which are transmitted over a serial interface using a **USB to Serial TTL Converter**.

The driver collects this data, processes it, and publishes it to an MQTT broker, enabling real-time data delivery to downstream systems that subscribe to these topics. The driver ensures seamless and accurate transmission of the data to an MQTT broker for further processing or monitoring.

### Key Features:
- **USB to Serial TTL Conversion**: Handles the USB data received from the soil moisture monitoring station via a Serial TTL interface.
- **Data Publishing via MQTT**: Publishes sensor data (such as salinity, humidity, and temperature) to an MQTT broker for real-time monitoring.
- **Supports Multiple Sensor Types**: Designed to handle multiple data origins, ensuring scalability as more sensors are added to the system.
- **Cross-Platform Support**: Designed to run on Linux, particularly on ARM64 devices like Raspberry Pi.

### Key Technologies:
- **C#**: Core language used for the driver and MQTT client implementation.
- **MQTT**: Data is published to an MQTT broker using the [MQTTnet](https://github.com/dotnet/MQTTnet) library.
- **Serial Communication**: Handles communication via USB/Serial TTL to gather data from the monitoring station.

---

## Automated Installation and Publishing (ARM64 and x64 only)

### Running the Automated Scripts

1. **Download the Setup Script**:
   - Installs the required .NET SDK for your architecture (`x64`, `arm64`).
   
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Download the Publish Script**:
   - Publishes the project, turning it into an executable, and ensures serial port permissions are correctly set.
   
   ```bash
   chmod +x publish.sh
   ./publish.sh
   ```

After running these scripts, the .NET SDK will be installed, and the project will be published, ready to run.

---

## Manual Installation

1. **Install Required Dependencies**:
   ```bash
   sudo apt update
   sudo apt install tar
   ```

2. **Download the .NET 8.0 SDK** from [here](https://dotnet.microsoft.com/en-us/download/dotnet/8.0).

3. **Extract and Setup SDK**:
   ```bash
   mkdir -p $HOME/dotnet
   tar -zxf dotnet-sdk-8.0.100-linux-arm64.tar.gz -C $HOME/dotnet
   ```

4. **Set Environment Variables** in your `.bashrc`:
   ```bash
   export DOTNET_ROOT=$HOME/dotnet
   export PATH=$HOME/dotnet:$PATH
   source ~/.bashrc
   ```

5. **Verify Installation**:
   ```bash
   dotnet --version
   ```

---

## Publish and Run the Project

To publish the project:
```bash
dotnet publish -c Release -r linux-arm64 --self-contained
```

Navigate to the directory where the published files are located and make the file executable:
```bash
cd bin/Release/net8.0/linux-arm64/publish
sudo chmod +x DriverUSB
```

To run the application:
```bash
./DriverUSB
```

---

## Serial Port Permissions

To access the serial port (`/dev/ttyUSB0`), you need to be in the `dialout` group:
```bash
sudo usermod -aG dialout $USER
```

Log out and log back in for the changes to take effect.

---

## Project Code Structure

The project contains the following files:

1. **Program.cs**: Main entry point of the program. Manages communication between the XBee module and the MQTT broker. This file handles the serial data reception and publishes sensor data to the broker.
   
2. **XBee.cs**: A class responsible for managing the serial communication with the XBee module, handling data reception, and ensuring data is correctly transmitted. 

3. **Sensor.cs**: A class that processes the raw data received from the soil moisture sensor. It parses the data, extracting important metrics such as humidity, salinity, temperature, and more.

---

## Using GPIOs on Raspberry Pi

If you prefer to use GPIOs instead of USB, configure the serial port and modify the code to use the GPIO pins for communication. 

Make sure to:
1. **Enable Serial Port**: 
   ```bash
   sudo raspi-config
   ```

2. **Connect GPIO Pins**: Use GPIO 14 (TX) and GPIO 15 (RX).

Modify the serial port in the code to use `/dev/serial0` or `/dev/ttyS0`:
```csharp
xbee.XBeeClient("/dev/serial0");
```

---

### Serial Port Troubleshooting

If you encounter issues accessing the serial port, ensure you are part of the `dialout` group, and no other process is using the port.

---

## Data Publishing via MQTT

Sensor data is published to the MQTT broker under structured topics like:

```
data/coordinator/sensor/soil/<device_id>/<data_type>
```

For example:
- `data/coordinator/sensor/soil/123/humidity`
- `data/coordinator/sensor/soil/123/salinity`
- `data/coordinator/sensor/soil/123/temperature`

Each MQTT message includes both the sensor value and the timestamp of the reading.

---

## For Collaborators

### Setting up Blackbox for File Encryption

To securely encrypt sensitive files in this project using **StackExchange Blackbox**, follow these steps:

#### 1. Install `BlackBox`
You can automatically install StackExchange Blackbox via the following commands:

```bash
git clone https://github.com/StackExchange/blackbox.git
cd blackbox
sudo make copy-install
```
This will copy the necessary files into `/usr/local/bin`.

#### 2. Obtain the Encoded GPG Keys
The **public** and **private** Base64-encoded GPG keys are stored in the repository's "Secrets." 
Ask the project maintainer to share the keys with you if you do not have access yet.

You will receive:
- A **Base64-encoded public key**
- A **Base64-encoded private key**

#### 3. Import the Public Key
Once you receive the **Base64-encoded public key**, use the following command to decode and import it:

```bash
echo "base64_encoded_public_key" | base64 --decode | gpg --import
```

- Replace `base64_encoded_public_key` with the actual Base64-encoded string of the public key.

#### 4. Import the Private Key
After importing the public key, you'll also need to import the **private key** for decryption purposes. To do that, use the following command:

```bash
echo "base64_encoded_private_key" | base64 --decode | gpg --import
```

- Replace `base64_encoded_private_key` with the actual Base64-encoded string of the private key.

#### 5. Verify the Import
You can verify if both keys were successfully imported with the following command:

```bash
gpg --list-secret-keys
```

This will list the GPG keys on your system, and you should see both the public and private key associated with your GPG email.

#### 6. Decrypt Files with `BlackBox`
With both the public and private keys imported, you can now decrypt the files in your project:

```bash
blackbox_decrypt_all_files
```

This command will decrypt all files that were encrypted with Blackbox, using your imported GPG keys.