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

1. **Install `BlackBox`:**
   - **macOS**:
     ```bash
     brew install blackbox
     ```
   - **Linux (Debian/Ubuntu)**:
     ```bash
     sudo apt-get install blackbox
     ```
   - **Windows**:
     - On Windows, you can use `WSL` (Windows Subsystem for Linux) to install `BlackBox` the same way as on Linux, or set up a Unix-like terminal environment using tools like Git Bash and follow the Linux installation steps.

2. **Retrieve the Encrypted GPG Key:**
   - The GPG key is stored as a secret in the repository via AWS Secrets Manager.
   - Request access from the project maintainer to retrieve the GPG key

3. **Import the GPG Key on Your Machine:**
   - Once you have obtained the GPG key, import it using the following command:
     ```bash
     echo "base64_encoded_key" | base64 --decode | gpg --import
     ```
   - Replace `"base64_encoded_key"` with the actual base64-encoded GPG key value provided to you.

4. **Verify the Key Import:**
   - After importing, verify that the key was successfully added by running:
     ```bash
     gpg --list-keys
     ```
   - You should see the imported GPG key in the list of available keys.

5. **Decrypt Files Using `BlackBox`:**
   - With the GPG key imported, run the following command to decrypt all files in the repository:
     ```bash
     blackbox_decrypt_all_files
     ```
   - This will decrypt all protected files, making them accessible for your work.