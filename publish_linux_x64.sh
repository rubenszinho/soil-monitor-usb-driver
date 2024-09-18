#!/bin/bash

echo "Publicando o projeto..."
projeto_dir="/home/rubenszinho/usb-driver"
cd "$projeto_dir"
dotnet publish -c Release -r linux-x64 --self-contained

echo "Tornando o arquivo executável..."
# Substitua "DriverUSB" pelo nome do seu executável
sudo chmod +x DriverUSB/bin/Release/net8.0/linux-x64/publish/DriverUSB

# Adiciona o usuário ao grupo dialout para permissões de porta serial
echo "Adicionando o usuário ao grupo dialout..."
sudo usermod -aG dialout $USER

echo "Você precisa sair e entrar novamente para que as alterações de grupo tenham efeito."

echo "Configuração concluída!"
echo "Para executar o aplicativo, navegue até o diretório de publicação e execute:"
echo "cd bin/Release/net8.0/linux-x64/publish/"
echo "./DriverUSB"
