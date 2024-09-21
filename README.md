# Passos para Rodar um Projeto .NET no Linux

Driver USB da estação de monitoramento de umidade do solo.

## Instalação do .NET 8.0 no Linux

### Usando o Snap (Recomendado)

1. **Instalar o Snap**:

```bash
   sudo apt update
   sudo apt install snapd
```
   
3. **Instalar o .NET SDK:**

```bash
   sudo snap install dotnet-sdk --channel=8.0 --classic
```
   
4. **Configurar o Alias:**
   
```bash
   sudo snap alias dotnet-sdk.dotnet dotnet
```

### Usando o Script de Instalação
1. Baixar o Script de Instalação:

```bash
  mkdir $HOME/dotnet_install && cd $HOME/dotnet_install
  curl -L https://aka.ms/install-dotnet-preview -o install-dotnet-preview.sh
```

4. Executar o Script:
   
```bash
   sudo bash install-dotnet-preview.sh
```
   
### Verificar a Instalação

```bash
   dotnet --version
```
   
   Isso deve retornar a versão do .NET instalada. O projeto foi feito na versão 8.0.

## Publicar o Projeto:

No seu ambiente de desenvolvimento (ou terminal), navegue até o diretório do seu projeto.
Use o comando a seguir para publicar o projeto, criando uma versão que pode ser executada no Linux:

```bash
  dotnet publish -c Release -r linux-x64 --self-contained
```
  
Este comando cria uma pasta publish dentro do diretório bin/Release/net8.0/linux-x64, contendo todos os arquivos necessários para executar o aplicativo.

## Executar o Aplicativo:

No terminal do Linux, navegue até o diretório onde você copiou os arquivos publicados.
Torne o arquivo executável com o comando:

```bash
  chmod +x DriverUSB
```

Execute o aplicativo com:

```bash
  ./DriverUSB
```

## Considerações
Permissões de Porta Serial: Certifique-se de que você tem as permissões necessárias para acessar portas seriais no Linux. Você pode precisar adicionar seu usuário ao grupo dialout:

```bash
  sudo usermod -aG dialout $USER
```

Depois, reinicie a sessão ou o sistema para que as alterações tenham efeito.

Dependências: Se você optou por não usar a opção --self-contained, certifique-se de que o .NET Runtime está instalado no sistema Linux.

Erros de Execução: Se encontrar erros, verifique as mensagens de log para diagnosticar problemas, como portas incorretas ou dispositivos não conectados.

# Usando GPIOs no Raspberry ao invés da porta USB

Para usar uma porta serial em um Raspberry Pi através de GPIOs, você precisará configurar o Raspberry Pi para usar os pinos GPIO como uma porta serial e depois ajustar seu código para abrir essa porta. Aqui estão os passos gerais para fazer isso:
Configuração do Raspberry Pi


## Habilitar a Porta Serial:

No Raspberry Pi, você pode habilitar a porta serial usando o raspi-config.

```bash  
   codesudo raspi-config
```

Navegue até Interfacing Options > Serial.
Escolha No quando perguntado se você quer que o console use a porta serial.
Escolha Yes para habilitar a interface serial.

## Conectar os Pinos GPIO:

Conecte os pinos GPIO 14 (TX) e GPIO 15 (RX) aos dispositivos que você deseja comunicar.
Certifique-se de usar um conversor de nível lógico se o dispositivo não operar em 3.3V.

## Alterações no Código
No seu código .NET, você precisará abrir a porta serial correta. O nome da porta pode variar, mas geralmente será algo como /dev/serial0 ou /dev/ttyS0.
Aqui está um exemplo de como você pode abrir a porta serial em C#:


```csharp
using System;
using System.IO.Ports;
class Program
{
    static void Main()
    {
        // Substitua "/dev/serial0" pelo nome correto da porta serial
        string portName = "/dev/serial0"; // ou "/dev/ttyS0"
        int baudRate = 9600; // Ajuste o baud rate conforme necessário

        using (SerialPort serialPort = new SerialPort(portName, baudRate))
        {
            try
            {
                serialPort.Open();
                Console.WriteLine("Porta serial aberta com sucesso!");

                // Exemplo de escrita na porta
                serialPort.WriteLine("Olá, Raspberry Pi!");

                // Exemplo de leitura da porta
                string response = serialPort.ReadLine();
                Console.WriteLine("Resposta recebida: " + response);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Erro ao abrir a porta serial: " + ex.Message);
            }
        }
    }
}
```

## Considerações

Permissões: Certifique-se de que o usuário que está executando o programa tem permissão para acessar a porta serial. Você pode precisar adicionar o usuário ao grupo dialout:

```bash 
   codesudo usermod -aG dialout $USER
```

Configuração do Baud Rate: Ajuste o baud rate e outras configurações da porta serial para corresponder ao dispositivo conectado.

Bibliotecas: Certifique-se de que o .NET Core está instalado corretamente no Raspberry Pi e que você tem acesso à biblioteca System.IO.Ports.
