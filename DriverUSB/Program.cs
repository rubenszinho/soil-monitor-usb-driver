using DriverUSB;
using System;

class Program
{
    private static XBee xbee;
    private static Sensor sensor;

    static void Main(string[] args)
    {
        Console.WriteLine("Início do Driver USB/Serial do IrrigoSystem!");

        xbee = new XBee();
        xbee.RecebeDados += XBee_DataReceived;
        xbee.XBeeClient("COM4"); // nome da porta. No Linux, as portas seriais são geralmente
                                 // nomeadas como / dev / ttyUSB0, / dev / ttyS0, etc.
                                 // Certifique - se de que seu código está configurado para
                                 // acessar a porta correta.
        xbee.Connect();

        sensor = new Sensor();

        // Adiciona uma pausa para manter o programa em execução
        Console.WriteLine("Pressione qualquer tecla para sair...");
        Console.ReadKey();
    }

    private static void XBee_DataReceived(byte tamanho, byte adress, byte[] bufferBytes)
    {
        switch (tamanho) // seleciona pelo byte de tamanho do pacote XBEE
        {
            case 0x4D:
                {
                    sensor.recebeDados(bufferBytes);
                    // basta selecionar a variável do sensor que deseja imprimir
                    Console.WriteLine(sensor.SensorId.ToString());
                    Console.WriteLine(sensor.Umidade.ToString());
                    Console.WriteLine(sensor.Salinidade.ToString());
                    Console.WriteLine(sensor.Tsensor.ToString());
                }
                break;
        }
    }
}
