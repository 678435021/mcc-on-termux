#!/usr/bin/bash
dir=$(pwd)

read -p "Do you have 64 bit ARM processor [Y/n] (n for 32 bit): " arch64

#pkg update --assume-yes
#pkg upgrade --assume-yes
#pkg install proot wget --assume-yes

# Install ubuntu
cd $PREFIX/bin
wget -O ubuntu-installer https://raw.githubusercontent.com/MFDGaming/ubuntu-in-termux/master/ubuntu.sh
chmod +x ubuntu-installer
echo Y | ubuntu-installer
mv startubuntu.sh startubuntu
chmod +x startubuntu

# Install MCC
installMCC='
apt update -y && apt upgrade -y
apt install wget nano unzip libc6 libgcc1 libgssapi-krb5-2 libstdc++6 zlib1g libicu70 libssl3 libatomic1 -y

cd /root

# install dotnet
if [ "'${arch64,,}'" == "y" ] || [ "'$arch64'" == "" ]; then
	arch=arm64
	mccDlLink=https://github.com/MCCTeam/Minecraft-Console-Client/releases/latest/download/MinecraftClient-linux-arm64.zip
	echo Downloading 64 bit version of dotnet6
	wget -nc -O dotnet6-$arch.tar.gz https://download.visualstudio.microsoft.com/download/pr/901f7928-5479-4d32-a9e5-ba66162ca0e4/d00b935ec4dc79a27f5bde00712ed3d7/dotnet-sdk-6.0.400-linux-arm64.tar.gz
else
	arch=arm
	mccDlLink=https://github.com/MCCTeam/Minecraft-Console-Client/releases/download/brigadier-dev-prerelease/MinecraftClient-linux-armv6.zip
	echo Downloading 32 bit version of dotnet6
	wget -nc -O dotnet6-$arch.tar.gz https://download.visualstudio.microsoft.com/download/pr/cf567026-a29a-41aa-bc3a-e4e1ad0df480/0925d411e8e09e31ba7a39a3eb0e29af/aspnetcore-runtime-6.0.8-linux-arm.tar.gz
fi

export DOTNET_ROOT=/usr/lib/.dotnet
DOTNET_FILE=dotnet6-$arch.tar.gz
rm -rf "$DOTNET_ROOT/*"
mkdir -p "$DOTNET_ROOT" && tar zxf "$DOTNET_FILE" -C "$DOTNET_ROOT"
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
echo -e "export DOTNET_ROOT=/root/.dotnet/"\n"export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools" >> /root/.bashrc

#install mcc
mkdir /usr/bin/MinecraftConsoleClient
cd /usr/bin/MinecraftConsoleClient
wget -O MinecraftClient-linux-$arch.zip $mccDlLink
unzip MinecraftClient-linux-$arch.zip
rm MinecraftClient-linux-$arch.zip
chmod +x MinecraftClient
cd ..
echo /usr/bin/MinecraftConsoleClient/MinecraftClient > mcc
chmod +x mcc
'
cd $dir
$PREFIX/bin/startubuntu "$installMCC"
echo 'startubuntu cd ~/MinecraftConsoleClient; mcc' > $PREFIX/bin/
ln -s $PREFIX/bin/ubuntu-fs/root/MinecraftConsoleClient ~/MinecraftConsoleClient
chmod +x $PREFIX/bin/mcc
echo 'Installation complete'
echo "run 'mcc' to start Minecraft Console Client"
echo 'Minecraft Console Client config directory is at ~/MinecraftConsoleClient'