using DriverUSB;
using DriverUSB;
using System;
using MQTTnet;
using MQTTnet.Client;
using System.Text;
using System.Threading.Tasks;

class Program
{
    private static XBee xbee;
    private static Sensor sensor;
    private static IMqttClient mqttClient;

    static async Task Main(string[] args)
    {
        Console.WriteLine("Início do Driver USB/Serial do IrrigoSystem!");

        var factory = new MqttFactory();
        mqttClient = factory.CreateMqttClient();

        var options = new MqttClientOptionsBuilder()
            .WithClientId("IrrigoSystemPublisher")
            .WithTcpServer("localhost", 1883);

        await mqttClient.ConnectAsync(options.Build(), CancellationToken.None);
        Console.WriteLine("Conectado ao broker MQTT.");

        xbee = new XBee();
        xbee.RecebeDados += XBee_DataReceived;
        xbee.XBeeClient("/dev/ttyUSB0");
        xbee.Connect();

        sensor = new Sensor();

        Console.WriteLine("Pressione qualquer tecla para sair...");
        Console.ReadKey();
    }

    private static async void XBee_DataReceived(byte tamanho, byte address, byte[] bufferBytes)
    {
        if (tamanho == 0x4D)
        {
            {
                sensor.recebeDados(bufferBytes);
                string deviceId = sensor.SensorId.ToString();
                string[] dataTypes = new string[] { "humidity", "salinity", "temperature" };
                double[] measuredValues = new double[] { sensor.Umidade, sensor.Salinidade, sensor.Tsensor };
                DateTime timestamp = DateTime.Parse(sensor.dadosSensorIrrigacao);

                for (int i = 0; i < measuredValues.Length; i++)
                {
                    string payload = $"{{ \"value\": \"{measuredValues[i]}\", \"timestamp\": \"{timestamp.ToString("o")}\" }}";

                    string topic = $"data/coordinator/sensor/soil/{deviceId}/{dataTypes[i]}";

                    var message = new MqttApplicationMessageBuilder()
                        .WithTopic(topic)
                        .WithPayload(payload)
                        .WithQualityOfServiceLevel(MQTTnet.Protocol.MqttQualityOfServiceLevel.ExactlyOnce)
                        .WithRetainFlag()
                        .Build();

                    if (mqttClient.IsConnected)
                    {
                        await mqttClient.PublishAsync(message, CancellationToken.None);
                        Console.WriteLine($"Published {dataTypes[i]} data to {topic} with timestamp.");
                    }
                    else
                    {
                        Console.WriteLine($"Failed to publish {dataTypes[i]} data. MQTT client not connected.");
                    }
                }
            }
        }
    }
}
