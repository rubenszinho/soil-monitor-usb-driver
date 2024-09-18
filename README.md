# Steps to Run a .NET Project on Linux

USB driver for the soil moisture monitoring station.

## Automated Installation and Publishing (arm64 and x64 only)

To simplify the process of setting up and publishing the project, automated scripts have been provided. These scripts will help you install the correct .NET SDK for your architecture and publish the project without manual intervention.

### Running the Automated Scripts

1. **Download the Setup Script**:
   - This script installs the required .NET SDK based on your chosen architecture (e.g., `x64`, `arm64`).
   
   To run the script:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   Follow the on-screen instructions to select your target architecture, and the script will handle the rest.

2. **Download the Publish Script**:
   - This script publishes the project, turning it into an executable, and ensures serial port permissions are correctly set.
   
   To run the script:

   ```bash
   chmod +x publish.sh
   ./publish.sh
   ```

   This script also lets you choose the architecture for the publish target and automatically sets the necessary permissions for accessing `/dev/ttyUSB0`.

After running these scripts, the .NET SDK will be installed, and the project will be published, ready to run on your system.

---

## Installing .NET 8.0 on Linux

### Manual Installation

1. **Install Required Dependencies**:

   ```bash
   sudo apt update
   sudo apt install tar
   ```

2. **Download the .NET 8.0 SDK**:

   Navigate to https://dotnet.microsoft.com/en-us/download/dotnet/8.0 page and download the most suitable SDK for you.

3. **Create Directory and Extract SDK**:

   ```bash
   mkdir -p $HOME/dotnet
   tar -zxf dotnet-sdk-8.0.100-linux-arm64.tar.gz -C $HOME/dotnet
   ```

4. **Set Environment Variables**:

   Add the following lines to your `.bashrc` to make the SDK available in future sessions:

   ```bash
   vim ~/.bashrc
   ```

   Add:

   ```bash
   # .NET SDK environment setup
   export DOTNET_ROOT=$HOME/dotnet
   export PATH=$HOME/dotnet:$PATH
   ```

   Save the file and reload your shell:

   ```bash
   source ~/.bashrc
   ```

5. **Verify Installation**:

   ```bash
   dotnet --version
   ```

   This should return the installed version, like `8.0.100`.

## Publish the Project:

In your development environment (or terminal), navigate to the project directory.
Use the following command to publish the project, creating a version that can run on Linux ARM64 (for Raspberry Pi), linux-arm64 flag must be changed depending on your system's architecture:

```bash
  dotnet publish -c Release -r linux-arm64 --self-contained
```

This command creates a `publish` folder inside the `bin/Release/net8.0/linux-arm64` directory, containing all the files necessary to run the application.

## Run the Application:

1. Navigate to the directory where the published files are located:

   ```bash
   cd bin/Release/net8.0/linux-arm64/publish
   ```

2. Make the file executable with the following command:

   ```bash
   sudo chmod +x DriverUSB
   ```

3. Run the application with:

   ```bash
   ./DriverUSB
   ```


## Considerations

### Serial Port Permissions:

To access the serial port `/dev/ttyUSB0`, you need the appropriate permissions. Add your user to the `dialout` group:

```bash
  sudo usermod -aG dialout $USER
```

Log out and log back in (or reboot) for the changes to take effect.

### Serial Port Troubleshooting:

If you get an "Access to the port ttyUSB0 is denied" error, ensure that:

- The correct permissions are set (you are in the `dialout` group).
- No other processes are using `/dev/ttyUSB0`.

## Using GPIOs on Raspberry Pi Instead of the USB Port

To use the serial port via GPIO pins on a Raspberry Pi, you'll need to configure the GPIOs as a serial port.

### Enable the Serial Port:

1. Run the following command to open the configuration tool:

   ```bash
   sudo raspi-config
   ```

2. Navigate to `Interfacing Options > Serial`.

3. When asked if you want the console to use the serial port, choose `No`.

4. Choose `Yes` to enable the serial interface.

### Connect the GPIO Pins:

Connect the **GPIO 14 (TX)** and **GPIO 15 (RX)** to the devices you wish to communicate with. If the device operates at a voltage different than 3.3V, use a logic level converter.

### Code Modifications

In your .NET code, open the correct serial port. The port name could be `/dev/serial0` or `/dev/ttyS0`.

Example code for opening a serial port in C#:

```csharp
    static void Main(string[] args)
    {
        Console.WriteLine("Início do Driver USB/Serial do IrrigoSystem!");

        xbee = new XBee();
        xbee.RecebeDados += XBee_DataReceived;
        xbee.XBeeClient("/dev/ttyUSB0"); // Port name. On Linux, serial ports are usually
                                 // named as / dev / ttyUSB0, / dev / ttyS0, etc.
                                 // Ensure that this part is set following the correct format
        xbee.Connect();

        sensor = new Sensor();

        Console.WriteLine("Pressione qualquer tecla para sair...");
        Console.ReadKey();
    }

    private static void XBee_DataReceived(byte tamanho, byte adress, byte[] bufferBytes)
    {
        switch (tamanho)
        {
            case 0x4D:
                {
                    sensor.recebeDados(bufferBytes);
                    Console.WriteLine(sensor.SensorId.ToString());
                    Console.WriteLine(sensor.Umidade.ToString());
                    Console.WriteLine(sensor.Salinidade.ToString());
                    Console.WriteLine(sensor.Tsensor.ToString());
                }
                break;
        }
    }
```

### GPIO Permissions:

Make sure your user has permission to access the serial port. Add your user to the `dialout` group if necessary:

```bash
  sudo usermod -aG dialout $USER
```

### Baud Rate Configuration:

Make sure the baud rate and other serial port settings match those of the connected device.

### Libraries:

Ensure that .NET is installed correctly and that you have access to the `System.IO.Ports` library.